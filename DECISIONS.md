# DECISIONS.md — Wholefin AWS / Terraform

> תיעוד החלטות ארכיטקטוניות, הנמקות, ומה שלא כתוב בקוד.
> עדכן כאן כל פעם שמתקבלת החלטה משמעותית.

---

## 🗂️ מבנה הפרויקט

### Multi-environment, single codebase
- **החלטה:** קוד אחד + `*.tfvars` לכל סביבה (sand/dev/stage/prod)
- **הנמקה:** מונע drift בין סביבות, קל לתחזוקה
- **סביבות:**
  | Environment | Account ID     | CIDR          |
  |-------------|----------------|---------------|
  | sand        | 844486820647   | 10.20.0.0/16  |
  | dev         | 148849676838   | 10.21.0.0/16  |
  | stage       | 493643818771   | TBD           |
  | prod        | 628743726312   | TBD           |
  | mgmt        | 934853894604   | N/A (ECR hub) |

### Backend — S3 + DynamoDB per account
- **החלטה:** State file נפרד לכל חשבון AWS (`wholefin-tfstate-{env}-{account_id}`)
- **הנמקה:** בידוד מלא בין סביבות, אין סכנת לכתיבה בטעות על prod מתוך dev
- **נעילה:** DynamoDB table `wholefin-tfstate-lock`

---

## 🌐 VPC / Networking

### 3-tier architecture (Public / App / Data)
- **החלטה:** 3 שכבות subnet נפרדות לכל AZ
- **הנמקה:** הפרדה ברורה — ECS ב-app tier, RDS ב-data tier, ALB בלבד ב-public
- **AZs:** a + b בלבד (שתיים מספיקות, חוסך עלויות)

### NAT Gateway — single (AZ a)
- **החלטה:** NAT Gateway יחיד ב-AZ a (לא HA NAT)
- **הנמקה:** חיסכון בעלויות לסביבות non-prod; לפני prod לשקול dual NAT
- **שים לב:** אם AZ a נופל — app + data subnets ב-AZ b מאבדים outbound internet

### אין NAT Instance
- **החלטה:** NAT Gateway מנוהל ולא NAT EC2 instance
- **הנמקה:** פחות תחזוקה, HA built-in, ה-overhead העלותי מוצדק

---

## ⚙️ Compute (ECS)

### ECS Fargate (לא EC2)
- **החלטה:** ECS עם Fargate launch type
- **הנמקה:** serverless containers — אין ניהול EC2, scaling אוטומטי

### ALB public, ECS private
- **החלטה:** ALB ב-public subnets, ECS tasks ב-app subnets (private)
- **הנמקה:** ECS tasks לא חשופים ישירות לאינטרנט; תנועה רק דרך ALB

---

## 🗄️ Database (RDS)

### Aurora PostgreSQL Serverless v2
- **החלטה:** Aurora cluster עם Serverless v2 scaling (0.5–1.0 ACU)
- **הנמקה:** עלות נמוכה ב-non-prod (scale to near-zero), production-grade engine
- **גרסה:** PostgreSQL 17.4
- **⚠️ סיסמה:** `TempPassword123!` — **לא לפרוד! להעביר ל-Secrets Manager לפני prod**

### RDS ב-data subnets בלבד
- **החלטה:** `db_subnet_group` מצביע על `data_subnet_ids` בלבד
- **הנמקה:** RDS לא נגיש מה-public ולא ישירות מה-app — רק דרך SG rules (VPC CIDR)

---

## 🔐 IAM

### Danny-TF Role (cross-account assume)
- **החלטה:** בכל חשבון יש role `Danny-TF`
- **Principal:** `arn:aws:iam::061486777167:role/AmazonSSMRoleForInstancesQuickSetup`
- **ExternalId:** `52a15c10-bcf9-43f4-aa7b-dbb937267218`
- **הנמקה:** גישה מרכזית לכל החשבונות ממקום אחד, ללא keys

---

## 🌍 CloudFront + WAF

### us-east-1 provider נפרד
- **החלטה:** provider עם alias `us_east_1` לכל משאבי CloudFront/WAFv2
- **הנמקה:** AWS מחייב us-east-1 ל-CloudFront scope WAF ולאישורי ACM ל-CF

### ACM Wildcard — `*.wholefin.ai`
- **סביבת sand:** `arn:aws:acm:us-east-1:844486820647:certificate/ab25ec34-...`
- **סביבות אחרות:** צריך ACM certificate ב-us-east-1 של אותו חשבון

---

## 🧩 Serverless (Lambda + CloudFront)

### ECR ב-mgmt account
- **החלטה:** כל Docker images נמצאים ב-ECR של `wholefin-mgmt` (934853894604)
- **הנמקה:** registry מרכזי אחד, כל הסביבות שולפות משם
- **Variable:** `ecr_mgmt_account_id`

### Cognito תלוי ב-serverless
- **החלטה:** `module.cognito` מקבל את `cloudfront_domain` מ-`module.serverless`
- **הנמקה:** Cognito callback URLs מצביעות ל-CloudFront domain
- **`depends_on`:** cognito → serverless → lambda

---

## 🔐 כללי בטיחות (Destroy)

1. תמיד `terraform plan -destroy` קודם ולשלוח סיכום לסוקו
2. לחכות לאישור מפורש ("כן/אשר/destroy")
3. אסור `-auto-approve` על prod או על משאבים stateful (RDS עם data, S3 עם data)
4. כללים חלים על כל החשבונות

---

## 🌿 Terragrunt Migration (2026-05-07)

### Decision: Migrate to Terragrunt
- **הנמקה:** DRY backend config, dependency ordering אוטומטי, folder = environment
- **הגישה:** modules/ נשארים ללא שינוי — רק מוסיפים `live/` layer מעל

### מבנה חדש
```
wholefin-aws/
├── modules/          ← unchanged
├── terragrunt.hcl    ← root (remote_state + provider generation)
└── live/
    ├── sand/
    │   ├── account.hcl   ← env values (replaces sand.tfvars)
    │   ├── vpc/
    │   ├── iam/
    │   ├── secrets/
    │   ├── compute/
    │   ├── database/
    │   ├── lambda/
    │   ├── serverless/
    │   └── cognito/
    ├── dev/
    ├── stage/
    └── prod/
```

### Dependency graph (אוטומטי עם terragrunt)
```
vpc ──────────────────┐
iam ──────────────┐   ├──→ compute ──→ serverless ──→ cognito
secrets           └───┘         ↑
lambda ───────────────────────────→ serverless
database ←── vpc
```

### פקודות
```bash
# apply סביבה שלמה (בסדר נכון אוטומטי)
cd live/sand && terragrunt run-all apply

# module ספציפי
cd live/sand/vpc && terragrunt apply

# plan הכל
cd live/sand && terragrunt run-all plan
```

### Migration status
- [x] root `terragrunt.hcl` (remote_state + provider gen)
- [x] `account.hcl` לכל env (sand/dev/stage/prod)
- [x] כל modules של sand מ-scaffold
- [ ] dev/stage/prod — לעשות mirror מ-sand
- [ ] לבדוק עם `terragrunt run-all validate` על sand
- [ ] להסיר `backend.tf` ו-`*.tfvars` הישנים אחרי migration

---

## 📋 TODO / Open Questions

- [ ] להעביר DB password ל-Secrets Manager לפני prod
- [ ] לשקול dual NAT Gateway ב-prod (HA)
- [ ] ACM certificates לסביבות dev/stage/prod
- [ ] WAF rules — מה הפוליסי? (rate limit, geo block?)
- [ ] RDS backup retention — כמה ימים?
- [ ] Multi-AZ RDS instance לפרוד?

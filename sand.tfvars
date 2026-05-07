# wholefin-sand | Account: 844486820647
environment         = "sand"
aws_region          = "us-east-2"
ecr_mgmt_account_id = "934853894604"

acm_certificate_arn = "arn:aws:acm:us-east-1:844486820647:certificate/ab25ec34-e2b5-4fd4-a884-67f2591c525a"

vpc_cidr            = "10.20.0.0/16"
public_subnet_cidrs = ["10.20.0.0/24", "10.20.1.0/24"]
app_subnet_cidrs    = ["10.20.10.0/24", "10.20.11.0/24"]
data_subnet_cidrs   = ["10.20.20.0/24", "10.20.21.0/24"]

# wholefin-stage | Account: 493643818771
environment         = "stage"
aws_region          = "us-east-2"
ecr_mgmt_account_id = "934853894604"

acm_certificate_arn = "REPLACE_WITH_ACM_ARN_IN_US_EAST_1_FOR_STAGE_ACCOUNT"

vpc_cidr            = "10.22.0.0/16"
public_subnet_cidrs = ["10.22.0.0/24", "10.22.1.0/24"]
app_subnet_cidrs    = ["10.22.10.0/24", "10.22.11.0/24"]
data_subnet_cidrs   = ["10.22.20.0/24", "10.22.21.0/24"]

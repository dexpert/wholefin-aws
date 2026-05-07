# wholefin-dev | Account: 148849676838
environment         = "dev"
aws_region          = "us-east-2"
ecr_mgmt_account_id = "934853894604"

acm_certificate_arn = "REPLACE_WITH_ACM_ARN_IN_US_EAST_1_FOR_DEV_ACCOUNT"

vpc_cidr            = "10.21.0.0/16"
public_subnet_cidrs = ["10.21.0.0/24", "10.21.1.0/24"]
app_subnet_cidrs    = ["10.21.10.0/24", "10.21.11.0/24"]
data_subnet_cidrs   = ["10.21.20.0/24", "10.21.21.0/24"]

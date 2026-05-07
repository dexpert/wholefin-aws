# wholefin-prod | Account: 628743726312
environment         = "prod"
aws_region          = "us-east-2"
ecr_mgmt_account_id = "934853894604"

acm_certificate_arn = "REPLACE_WITH_ACM_ARN_IN_US_EAST_1_FOR_PROD_ACCOUNT"

vpc_cidr            = "10.23.0.0/16"
public_subnet_cidrs = ["10.23.0.0/24", "10.23.1.0/24"]
app_subnet_cidrs    = ["10.23.10.0/24", "10.23.11.0/24"]
data_subnet_cidrs   = ["10.23.20.0/24", "10.23.21.0/24"]

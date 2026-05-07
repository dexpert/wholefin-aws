include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env          = local.account_vars.locals
}

terraform {
  source = "../../../modules/lambda"
}

inputs = {
  environment         = local.env.environment
  aws_region          = local.env.aws_region
  ecr_mgmt_account_id = local.env.ecr_mgmt_account_id
}

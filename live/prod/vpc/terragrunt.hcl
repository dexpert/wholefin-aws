include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env          = local.account_vars.locals
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  environment         = local.env.environment
  aws_region          = local.env.aws_region
  vpc_cidr            = local.env.vpc_cidr
  availability_zones  = ["a", "b"]
  public_subnet_cidrs = local.env.public_subnet_cidrs
  app_subnet_cidrs    = local.env.app_subnet_cidrs
  data_subnet_cidrs   = local.env.data_subnet_cidrs
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env          = local.account_vars.locals
}

terraform {
  source = "../../../modules/database"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    vpc_id          = "vpc-00000000"
    data_subnet_ids = ["subnet-00000000", "subnet-11111111"]
    vpc_cidr        = "10.0.0.0/16"
  }
}

inputs = {
  environment     = local.env.environment
  aws_region      = local.env.aws_region
  vpc_id          = dependency.vpc.outputs.vpc_id
  private_subnets = dependency.vpc.outputs.data_subnet_ids
  vpc_cidr        = dependency.vpc.outputs.vpc_cidr
}

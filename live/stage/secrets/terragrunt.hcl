include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env          = local.account_vars.locals
}

terraform {
  source = "../../../modules/secrets"
}

dependency "database" {
  config_path = "../database"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    master_user_secret_arn = "arn:aws:secretsmanager:us-east-2:000000000000:secret:mock-rds-secret"
  }
}

inputs = {
  environment            = local.env.environment
  rds_master_secret_arn  = dependency.database.outputs.master_user_secret_arn
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env          = local.account_vars.locals
}

terraform {
  source = "../../../modules/cognito"
}

dependency "serverless" {
  config_path = "../serverless"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    cloudfront_domain = "mock.cloudfront.net"
  }
}

inputs = {
  environment       = local.env.environment
  aws_region        = local.env.aws_region
  cloudfront_domain = dependency.serverless.outputs.cloudfront_domain
}

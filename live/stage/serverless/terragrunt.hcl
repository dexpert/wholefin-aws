include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env          = local.account_vars.locals
}

terraform {
  source = "../../../modules/serverless"
}

dependency "compute" {
  config_path = "../compute"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    alb_dns_name = "mock-alb.us-east-2.elb.amazonaws.com"
  }
}

dependency "lambda" {
  config_path = "../lambda"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    function_url_hostname      = "mock.lambda-url.us-east-2.on.aws"
    test_edge_qualified_arn    = "arn:aws:lambda:us-east-1:000000000000:function:test:1"
  }
}

inputs = {
  environment                  = local.env.environment
  acm_certificate_arn          = local.env.acm_certificate_arn
  alb_dns_name                 = dependency.compute.outputs.alb_dns_name
  truthifi_lambda_url_hostname = dependency.lambda.outputs.function_url_hostname
  test_edge_lambda_arn         = dependency.lambda.outputs.test_edge_qualified_arn
}

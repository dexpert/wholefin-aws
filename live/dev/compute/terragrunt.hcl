include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env          = local.account_vars.locals
}

terraform {
  source = "../../../modules/compute"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    vpc_id          = "vpc-00000000"
    vpc_cidr        = "10.0.0.0/16"
    public_subnet_ids = ["subnet-00000000", "subnet-11111111"]
    app_subnet_ids    = ["subnet-22222222", "subnet-33333333"]
  }
}

dependency "iam" {
  config_path = "../iam"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    ecs_task_role_arn      = "arn:aws:iam::000000000000:role/mock-task-role"
    ecs_execution_role_arn = "arn:aws:iam::000000000000:role/mock-exec-role"
  }
}

inputs = {
  environment            = local.env.environment
  aws_region             = local.env.aws_region
  account_id             = local.env.account_id
  vpc_id                 = dependency.vpc.outputs.vpc_id
  vpc_cidr               = dependency.vpc.outputs.vpc_cidr
  public_subnets         = dependency.vpc.outputs.public_subnet_ids
  private_subnets        = dependency.vpc.outputs.app_subnet_ids
  ecs_task_role_arn      = dependency.iam.outputs.ecs_task_role_arn
  ecs_execution_role_arn = dependency.iam.outputs.ecs_execution_role_arn
}

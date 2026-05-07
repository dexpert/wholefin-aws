provider "aws" {
  region = var.aws_region
}

# CloudFront + WAFv2 (CLOUDFRONT scope) must live in us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

module "vpc" {
  environment         = var.environment
  source              = "./modules/vpc"
  aws_region          = var.aws_region
  vpc_cidr            = "10.20.0.0/16"
  availability_zones  = ["a", "b"]
  public_subnet_cidrs = ["10.20.0.0/24", "10.20.1.0/24"]
  app_subnet_cidrs    = ["10.20.10.0/24", "10.20.11.0/24"]
  data_subnet_cidrs   = ["10.20.20.0/24", "10.20.21.0/24"]
}

module "iam" {
  source      = "./modules/iam"
  environment = var.environment
}

module "secrets" {
  source      = "./modules/secrets"
  environment = var.environment
}

module "cognito" {
  source            = "./modules/cognito"
  environment       = var.environment
  aws_region        = var.aws_region
  cloudfront_domain = module.serverless.cloudfront_domain
  depends_on        = [module.serverless]
}

module "compute" {
  environment            = var.environment
  source                 = "./modules/compute"
  aws_region             = var.aws_region
  account_id             = data.aws_caller_identity.current.account_id
  vpc_id                 = module.vpc.vpc_id
  public_subnets         = module.vpc.public_subnet_ids
  private_subnets        = module.vpc.app_subnet_ids # ECS runs in app tier
  vpc_cidr               = module.vpc.vpc_cidr
  ecs_task_role_arn      = module.iam.ecs_task_role_arn
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  depends_on             = [module.vpc, module.iam]
}

module "database" {
  environment     = var.environment
  source          = "./modules/database"
  aws_region      = var.aws_region
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.data_subnet_ids # RDS runs in data tier
  vpc_cidr        = module.vpc.vpc_cidr
  depends_on      = [module.vpc]
}

module "lambda" {
  source      = "./modules/lambda"
  environment = var.environment
  aws_region  = var.aws_region
}

module "serverless" {
  environment                  = var.environment
  source                       = "./modules/serverless"
  alb_dns_name                 = module.compute.alb_dns_name
  acm_certificate_arn          = var.acm_certificate_arn
  truthifi_lambda_url_hostname = module.lambda.function_url_hostname

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  depends_on = [module.lambda]
}

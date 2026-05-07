provider "aws" {
  region = var.aws_region
}

# CloudFront + WAFv2 (CLOUDFRONT scope) must live in us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

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

module "compute" {
  environment     = var.environment
  source          = "./modules/compute"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
  private_subnets = module.vpc.app_subnet_ids # ECS runs in app tier

  vpc_cidr   = module.vpc.vpc_cidr
  depends_on = [module.vpc]
}

module "database" {
  environment     = var.environment
  source          = "./modules/database"
  aws_region      = var.aws_region
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.data_subnet_ids # RDS runs in data tier

  vpc_cidr   = module.vpc.vpc_cidr
  depends_on = [module.vpc]
}

module "serverless" {
  environment         = var.environment
  source              = "./modules/serverless"
  alb_dns_name        = module.compute.alb_dns_name
  acm_certificate_arn = var.acm_certificate_arn

  providers = {
    aws            = aws
    aws.us_east_1  = aws.us_east_1
  }
}

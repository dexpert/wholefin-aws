provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source               = "./modules/vpc"
  aws_region           = var.aws_region
  vpc_cidr             = "10.11.0.0/16"
  public_subnet_cidrs  = ["10.11.0.0/24", "10.11.1.0/24", "10.11.2.0/24"]
  private_subnet_cidrs = ["10.11.3.0/24", "10.11.4.0/24", "10.11.5.0/24", "10.11.6.0/24"]
}

module "compute" {
  source          = "./modules/compute"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
  private_subnets = module.vpc.private_subnet_ids
  
  vpc_cidr = module.vpc.vpc_cidr
  depends_on = [module.vpc]
}

module "database" {
  source          = "./modules/database"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnet_ids

  vpc_cidr = module.vpc.vpc_cidr
  depends_on = [module.vpc]
}

module "serverless" {
  source = "./modules/serverless"
}

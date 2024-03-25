terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.41.0"
    }
  }
}

provider "aws" {  
  region = "us-east-1"
}

data "archive_file" "bundle" {
  type        = "zip"
  source_dir  = "./Build"
  output_path = "bundle.zip"
}

module "s3"{
  source = "./modules/s3"
  bucket-name = "lavagna-bucket"
  key = "beanstalk/bundle.zip"
  bucket-source = data.archive_file.bundle.output_path
}

module "vpc" {
  source = "./modules/vpc"
  name = "lavagna-vpc"
}

module "sg"{
  source = "./modules/security_group"
  vpc-id = module.vpc.vpc-id
}

module "rds"{
  source = "./modules/rds"
  rds-sg-id = module.sg.rds-security-group-id
  public-subnets = module.vpc.public-subnets
}

module "beanstalk"{
  source = "./modules/beanstalk"
  public-subnets = module.vpc.public-subnets
  vpc-id = module.vpc.vpc-id
  lb-security-group = module.sg.elb-security-group-id
  beanstalk-instance-sg = module.sg.instance-security-group-id
  bucket = module.s3.bucket
  bucket-key = module.s3.bucket-key
  rds-db-name = module.rds.db-name
  rds-db-password = module.rds.password
  rds-db-username = module.rds.username
  rds-endpoint = module.rds.rds-instance-endpoint
}
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.41.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

module "beanstalk" {
  source = "./modules/beanstalk"
}

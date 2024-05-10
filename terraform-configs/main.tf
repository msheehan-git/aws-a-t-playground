terraform {
  backend "s3" {
    bucket = "tfstate-aws-bucket-23423f"
    key    = "aws-test/terraform.tfstate"
    region = "us-east-2"
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "vpc" {
  source = "./vpc"
}

module "network" {
  source            = "./network"
  playground_vpc_id = module.vpc.playground_vpc_id
}

module "secure" {
  source            = "./secure"
  playground_vpc_id = module.vpc.playground_vpc_id
}

module "nodes" {
  source                                  = "./nodes"
  playground_vpc_id                       = module.vpc.playground_vpc_id
  private_playground_subnet_us_east_1a_id = module.network.private_playground_subnet_us_east_1a_id
  aws_secure_group_id                     = [module.secure.aws_secure_group_id]
}


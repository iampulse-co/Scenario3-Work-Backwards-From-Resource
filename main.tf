terraform {
  required_version = "~> 1.1.2"

  required_providers {
    aws = {
      version = "~> 4.9.0"
      source  = "hashicorp/aws"
    }
  }
}

# Download AWS provider
provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      Owner = "Playground Scenario 3"
    }
  }
}

# Build staff policies
module "staff" {
  source = "./modules/staff"
}

# Build VPC and SGs
module "network" {
  source = "./modules/network"
}

# Build RDS DB
module "rds" {
  source        = "./modules/rds"
  rds_sg_id     = module.network.rds_sg_id
  db_subnets_id = module.network.db_subnets_id
  vpc_main_id   = module.network.vpc_main_id
}

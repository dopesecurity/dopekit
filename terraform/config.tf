terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0.0, < 6.0.0"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      "dope:deployer-id" = var.deployer_id
      "dope:service"     = var.service_name
      "dope:stack_name"  = var.stack_name
    }
  }

}

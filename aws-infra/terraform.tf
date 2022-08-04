###############################################################################
# Providers
###############################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.18.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.4.0"
    }
  }
}

provider "aws" {
  region = module.common.aws_region
  default_tags {
    tags = {
      Environment = "rancher-workshop"
      Owner       = module.common.owner
      Terraform   = "true"
    }
  }
}
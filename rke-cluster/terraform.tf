###############################################################################
# Providers
###############################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.18.0"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.24.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
  }
}

provider "aws" {
  region = module.common.aws_region
}

# Rancher2 
provider "rancher2" {
  api_url   = "https://${data.terraform_remote_state.aws_infra.outputs.rancher_url}"
  token_key = data.terraform_remote_state.rancher-server.outputs.admin_token
}

# Rancher2 administration provider
provider "rancher2" {
  alias = "admin"

  api_url   = "https://${data.terraform_remote_state.aws_infra.outputs.rancher_url}"
  token_key = data.terraform_remote_state.rancher-server.outputs.admin_token
  insecure  = true
}


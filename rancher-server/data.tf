data "terraform_remote_state" "aws_infra" {
    backend = "local"
    
    config = {
        path = "${path.root}/../aws-infra/terraform.tfstate"
    }
}

module "common" {
  source = "../common"
}
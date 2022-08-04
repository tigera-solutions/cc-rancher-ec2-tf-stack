# Load the common module, with all the variables.
module "common" {
  source = "../common"
}

# Import the output information from the aws_infra terraform deployment.
data "terraform_remote_state" "aws_infra" {
  backend = "local"

  config = {
    path = "${path.root}/../aws-infra/terraform.tfstate"
  }
}
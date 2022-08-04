#Use the latest Ubuntu 20.04 ami version
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"]
}

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

# Import the output information from the rancher-server terraform deployment.
data "terraform_remote_state" "rancher-server" {
  backend = "local"

  config = {
    path = "${path.root}/../rancher-server/terraform.tfstate"
  }
}


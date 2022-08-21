###############################################################################
# Bootstrap process to change the admin password
###############################################################################

# Testing until the rancher pod is up and running
resource "ssh_resource" "test_rancher" {
  depends_on = [
    ssh_resource.install_k3s
  ]
  host = data.terraform_remote_state.aws_infra.outputs.rancher_server_public_ip
  commands = [
    "until (k3s kubectl get  pod -l app=rancher-webhook -n cattle-system | grep Running); do echo 'Waiting for Rancher to start'; sleep 20; done"
  ]
  user        = module.common.node_username
  private_key = data.terraform_remote_state.aws_infra.outputs.private_key
}

# If this variable is present, it will override the password variable from the common module
#  `export TF_VAR_admin_password = <password>`

variable admin_password {
  type      = string
  default   = ""
  description = "Using a password defined as an environment paramenter, if available"
  sensitive = true
}

# Boostrapping the admin user with a new password
resource "rancher2_bootstrap" "admin" {
  depends_on = [
    ssh_resource.test_rancher
  ]

  provider = rancher2.bootstrap

  password  = var.admin_password != "" ? var.admin_password : module.common.admin_password
  telemetry = true
}
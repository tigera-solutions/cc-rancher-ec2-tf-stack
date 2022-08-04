###############################################################################
# K3s cluster installation for the Rancher Server 
###############################################################################

# K3s cluster installation
resource "ssh_resource" "install_k3s" {
  host = data.terraform_remote_state.aws_infra.outputs.rancher_server_public_ip
  commands = [
    "bash -c 'curl https://get.k3s.io | INSTALL_K3S_EXEC=\"server --node-external-ip ${data.terraform_remote_state.aws_infra.outputs.rancher_server_public_ip} --node-ip ${data.terraform_remote_state.aws_infra.outputs.rancher_server_private_ip}\" INSTALL_K3S_VERSION=${module.common.rancher_kubernetes_version} sh -'"
  ]
  user        = module.common.node_username
  private_key = data.terraform_remote_state.aws_infra.outputs.private_key
}

# Retrive the kubeconfig yaml for the K3s cluster
resource "ssh_resource" "retrieve_config" {
  depends_on = [
    ssh_resource.install_k3s
  ]
  host = data.terraform_remote_state.aws_infra.outputs.rancher_server_public_ip
  commands = [
    "sudo sed \"s/127.0.0.1/${data.terraform_remote_state.aws_infra.outputs.rancher_server_public_ip}/g\" /etc/rancher/k3s/k3s.yaml"
  ]
  user        = module.common.node_username
  private_key = data.terraform_remote_state.aws_infra.outputs.private_key
}
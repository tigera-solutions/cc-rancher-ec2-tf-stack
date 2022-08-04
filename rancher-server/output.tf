###############################################################################
# Output to be used in the RKE cluster provisioning
###############################################################################

output "admin_token" {
  value     = rancher2_bootstrap.admin.token
  sensitive = true
}

###############################################################################
# Dump the kubeconfig yaml to a file
###############################################################################

# Save kubeconfig file for interacting with the RKE cluster on your local machine
resource "local_file" "kube_config_server_yaml" {
  filename = format("%s/%s", "${path.root}/../common", "kube_config_server.yaml")
  content  = ssh_resource.retrieve_config.result
}

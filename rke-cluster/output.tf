###############################################################################
# Dump the kubeconfig yaml to a file
###############################################################################

resource "local_file" "kube_config_rke_yaml" {
  depends_on = [ rancher2_cluster_sync.sync_ec2 ]

  filename = format("%s/%s", "${path.root}/../common", "kube_config_${var.cluster_name != "" ? var.cluster_name : module.common.rancher_cluster_name}.yaml")
  content  = rancher2_cluster.rke_cluster.kube_config
}

resource "null_resource" "set-environment" {
  depends_on = [
    local_file.kube_config_rke_yaml
  ]
  provisioner "local-exec" {
    command = <<-EOT
      sed -i '' -e '/certificate/,+11 d' ${path.root}/../common/kube_config_${var.cluster_name != "" ? var.cluster_name : module.common.rancher_cluster_name}.yaml
      export KUBECONFIG=$KUBECONFIG:${path.root}/../common/kube_config_${var.cluster_name != "" ? var.cluster_name : module.common.rancher_cluster_name}.yaml
    EOT
  }
}
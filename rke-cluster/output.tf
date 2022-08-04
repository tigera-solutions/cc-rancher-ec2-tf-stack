###############################################################################
# Dump the kubeconfig yaml to a file
###############################################################################

resource "local_file" "kube_config_rke_yaml" {
  filename = format("%s/%s", "${path.root}/../common", "kube_config_${module.common.rancher_cluster_name}.yaml")
  content  = rancher2_cluster.rke_cluster.kube_config
}
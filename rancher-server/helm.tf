###############################################################################
# Installation of the cert-manager and the Rancher Server
###############################################################################

# Install cert-manager helm chart
resource "helm_release" "cert_manager" {
  depends_on = [
    local_file.kube_config_server_yaml
  ]
  name             = "cert-manager"
  chart            = "https://charts.jetstack.io/charts/cert-manager-v${module.common.cert_manager_version}.tgz"
  namespace        = "cert-manager"
  create_namespace = true
  wait             = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# Install Rancher helm chart
resource "helm_release" "rancher_server" {
  depends_on = [
    helm_release.cert_manager
  ]
  name             = "rancher"
  chart            = "https://releases.rancher.com/server-charts/latest/rancher-${module.common.rancher_version}.tgz"
  namespace        = "cattle-system"
  create_namespace = true
  wait             = true
  timeout          = "600"

  set {
    name  = "hostname"
    value = data.terraform_remote_state.aws_infra.outputs.rancher_url
  }

  set {
    name  = "replicas"
    value = "1"
  }

  set {
    name  = "bootstrapPassword"
    value = "admin"
  }

}

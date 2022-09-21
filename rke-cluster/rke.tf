###############################################################################
# Create a RKE Cluster
###############################################################################

# RKE Cluster
resource "rancher2_cluster" "rke_cluster" {
  name = "${var.cluster_name != "" ? var.cluster_name : module.common.rancher_cluster_name}-cluster"
  enable_cluster_monitoring = false
  enable_cluster_alerting   = false
  description               = "RKE Cluster"

  rke_config {
    network {
      plugin = "calico"
    }

    cloud_provider {
      name = "aws"
      aws_cloud_provider {
      }
    }

    authentication {
      strategy = "x509|webhook"
    }

    kubernetes_version = module.common.workload_kubernetes_version
  }
}

#Create a new rancher2 Node Template
# Create amazonec2 cloud credential
# As a good practice, you should never hardcode 
# secrets in your code, so first export the needed variables
#  `export TF_VAR_aws_access_key_id = <ACCESS_KEY>`
#  `export TF_VAR_aws_secret_access_key = <SECRET_KEY>`
resource "rancher2_cloud_credential" "cloud_credentials" {
  name        = "cloud-credentials"
  description = "Rancher Cloud Credentials"
  amazonec2_credential_config {
    access_key = var.aws_access_key_id
    secret_key = var.aws_secret_access_key
  }
}

# Node template for the nodes in the cluster
resource "rancher2_node_template" "rke_node_template" {
  name = "${var.cluster_name != "" ? var.cluster_name : module.common.rancher_cluster_name}_node_template"
  description         = "EC2 RKE-node Template"
  cloud_credential_id = rancher2_cloud_credential.cloud_credentials.id
  engine_install_url  = "https://releases.rancher.com/install-docker/20.10.sh"
  amazonec2_config {
    ami                  = data.aws_ami.ubuntu.id
    region               = module.common.aws_region
    security_group       = [data.terraform_remote_state.aws_infra.outputs.aws_security_group]
    vpc_id               = data.terraform_remote_state.aws_infra.outputs.vpc_id
    subnet_id            = data.terraform_remote_state.aws_infra.outputs.aws_subnet_id
    zone                 = module.common.aws_az
    instance_type        = module.common.instance_type
    iam_instance_profile = data.terraform_remote_state.aws_infra.outputs.aws_iam_profile_name
    ssh_user             = "ubuntu"
  }
}

# Create a the rancher2 master node
resource "rancher2_node_pool" "rke_master" {
  depends_on       = [rancher2_node_template.rke_node_template]
  cluster_id       = rancher2_cluster.rke_cluster.id
  name             = "${module.common.prefix}-${var.cluster_name != "" ? var.cluster_name : module.common.rancher_cluster_name}-master"
  hostname_prefix  = "${module.common.prefix}-${var.cluster_name != "" ? var.cluster_name : module.common.rancher_cluster_name}-master"
  node_template_id = rancher2_node_template.rke_node_template.id
  quantity         = 1
  control_plane    = true
  etcd             = true
  worker           = true
}

# Create a the rancher2 worker nodes
resource "rancher2_node_pool" "rke_node" {
  depends_on       = [rancher2_node_pool.rke_master]
  cluster_id       = rancher2_cluster.rke_cluster.id
  name             = "${module.common.prefix}-${var.cluster_name != "" ? var.cluster_name : module.common.rancher_cluster_name}-node"
  hostname_prefix  = "${module.common.prefix}-${var.cluster_name != "" ? var.cluster_name : module.common.rancher_cluster_name}-node"
  node_template_id = rancher2_node_template.rke_node_template.id
  quantity         = 2
  control_plane    = false
  etcd             = false
  worker           = true
}

# Glue the both nodes to the cluster
resource "rancher2_cluster_sync" "sync_ec2" {
  cluster_id = rancher2_cluster.rke_cluster.id
  node_pool_ids = [
    rancher2_node_pool.rke_master.id,
    rancher2_node_pool.rke_node.id
  ]
}
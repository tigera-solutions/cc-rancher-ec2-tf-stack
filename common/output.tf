###############################################################################
# Variables for AWS Infrastructure creation
###############################################################################

output "owner" {
  value = var.owner
}

output "prefix" {
  value = var.prefix
}

output "aws_region" {
  value = var.aws_region
}

output "aws_az" {
  value = var.aws_az
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "instance_type" {
  value = var.instance_type
}

output "workload_instance_type" {
  value = var.workload_instance_type
}

output "hosted_zone" {
  value = var.hosted_zone
}

output "domain_prefix" {
  value = var.domain_prefix
}

output "aws_access_key_id" {
  value = var.aws_access_key_id
}

output "aws_secret_access_key" {
  value = var.aws_secret_access_key
}

###############################################################################
# Variables for Rancher Installation
###############################################################################

output "rancher_kubernetes_version" {
  value = var.rancher_kubernetes_version
}

output "cert_manager_version" {
  value = var.cert_manager_version
}

output "rancher_version" {
  value = var.rancher_version
}

output "admin_password" {
  value = var.admin_password
}

###############################################################################
# Variables for RKE Installation
###############################################################################

output "workload_kubernetes_version" {
  value = var.workload_kubernetes_version
}

output "rancher_cluster_name" {
  value = var.rancher_cluster_name
}

###############################################################################
# Locals
###############################################################################

output "node_username" {
  value = local.node_username
}
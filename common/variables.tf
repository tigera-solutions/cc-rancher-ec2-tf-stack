###############################################################################
# Common variables to be used by all terraform apply phases
###############################################################################

variable "owner" {
  type        = string
  default     = "Regis Martins"
  description = "Name to be used in the Owner tag of the AWS resources"
}

variable "prefix" {
  type        = string
  default     = "regis"
  description = "The prefix will precede all the resources to be created for easy identification"
}

variable "aws_region" {
  type        = string
  default     = "ca-central-1"
  description = "AWS region to be used in the deployment"
}

variable "aws_az" {
  type        = string
  default     = "b"
  description = "AWS availability zone to be used in the deployment"
}

variable "vpc_cidr" {
  type        = string
  default     = "100.0.0.0/16"
  description = "VPC CIDR for the EC2 instances"
}

variable "instance_type" {
  type        = string
  default     = "t3a.medium"
  description = "Instance type used for Rancher server EC2 instance"
}

variable "workload_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance type used for RKE Cluster EC2 instance"
}

variable "hosted_zone" {
  type        = string
  default     = "tigera.rocks"
  description = "The hosted zone domain to be used for the Rancher server"
}

variable "domain_prefix" {
  type        = string
  default     = "rancher"
  description = "Domain prefix of the Rancher server. https://domain_prefix.hosted_zone (ie: https://rancher.tigera.rocks)"
}

###############################################################################
# Variables for Rancher Installation
###############################################################################

variable "rancher_kubernetes_version" {
  type        = string
  default     = "v1.22.9+k3s1"
  description = "Kubernetes version to use for Rancher server cluster"
}

variable "cert_manager_version" {
  type        = string
  default     = "1.7.1"
  description = "Version of cert-manager to install alongside Rancher (format: 0.0.0)"
}

variable "rancher_version" {
  type        = string
  default     = "2.6.5"
  description = "Rancher server version (format: v0.0.0)"
}

variable "admin_password" {
  type        = string
  default     = "rancherpassword"
  description = "Password to be defined for the admin user by the bootstrap (12 char. minimum)"
}

###############################################################################
# Variables for RKE Installation
###############################################################################

variable "workload_kubernetes_version" {
  type        = string
  default     = "v1.22.10-rancher1-1"
  description = "Kubernetes version to use for managed RKE cluster"
}

variable "rancher_cluster_name" {
  type        = string
  default     = "rke"
  description = "Prefix for the RKE cluster"
}

variable "aws_access_key_id" {
  type        = string
  default     = ""
  description = "export TF_VAR_aws_access_key_id = <ACCESS_KEY> for the Rancher server to provision the RKE cluster"
}

variable "aws_secret_access_key" {
  type        = string
  default     = ""
  description = "export TF_VAR_aws_secret_access_key = <SECRET_KEY> for the Rancher server to provision the RKE cluster"

}
###############################################################################
# Common variables to be used by all terraform apply phases
###############################################################################

locals {
  node_username = "ec2-user"
}
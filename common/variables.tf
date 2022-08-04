# Variables for AWS Infrastructure creation

variable "owner" {
  type    = string
  default = "Regis Martins"
}

variable "prefix" {
  type    = string
  default = "regis"
}

variable "aws_region" {
  type    = string
  default = "ca-central-1"
}

variable "aws_az" {
  type    = string
  default = "b"
}

variable "vpc_cidr" {
  type    = string
  default = "100.0.0.0/16"
}

variable "instance_type" {
  type        = string
  description = "Instance type used for Rancher server EC2 instance"
  default     = "t3a.medium"
}

variable "workload_instance_type" {
  type        = string
  description = "Instance type used for RKE Cluster EC2 instance"
  default     = "t3.medium"
}

variable "hosted_zone" {
  type    = string
  default = "tigera.rocks"
}

variable "domain_prefix" {
  type    = string
  default = "rancher-02"
}

variable "aws_access_key_id" {
  type        = string
  description = "export TF_VAR_aws_access_key_id = <ACCESS_KEY>"
  default = ""
}

variable "aws_secret_access_key" {
  type        = string
  description = "export TF_VAR_aws_secret_access_key = <SECRET_KEY>"
  default = ""
}

###############################################################################
# Variables for Rancher Installation

variable "rancher_kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for Rancher server cluster"
  default     = "v1.22.9+k3s1"
}

variable "cert_manager_version" {
  type        = string
  description = "Version of cert-manager to install alongside Rancher (format: 0.0.0)"
  default     = "1.7.1"
}

variable "rancher_version" {
  type        = string
  description = "Rancher server version (format: v0.0.0)"
  default     = "2.6.5"
}

variable "admin_password" {
  type        = string
  description = "Password to be defined for the admin user"
  default     = "calicorancher"
}

###############################################################################
# Variables for Rancher Installation

variable "workload_kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for managed workload cluster"
  default     = "v1.22.10-rancher1-1"
#  default     = "v1.20.4-rancher1-1"
}

variable "rancher_cluster_name" {
  type = string
  default = "rancherke"
}

###############################################################################
# Locals

locals {
  node_username = "ec2-user"
}
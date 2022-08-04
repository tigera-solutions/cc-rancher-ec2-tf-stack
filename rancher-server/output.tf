output "admin_token" {
  value = rancher2_bootstrap.admin.token
  sensitive = true
}


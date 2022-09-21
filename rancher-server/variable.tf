# If this variable is present, it will override the password variable from the common module
#  `export TF_VAR_admin_password = <password>`

variable admin_password {
  type      = string
  default   = ""
  description = "Using a password defined as an environment paramenter, if available"
  sensitive = true
}
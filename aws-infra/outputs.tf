###############################################################################
# Outputs to be used in the Rancher Server provisioning
###############################################################################

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "rancher_server_public_ip" {
  value = aws_eip.rancher_public_ip.public_ip
}

output "rancher_server_private_ip" {
  value = aws_instance.rancher_server.private_ip
}

output "private_key" {
  value     = tls_private_key.global_key.private_key_pem
  sensitive = true
}

output "rancher_url" {
  value = aws_route53_record.rancher_record.name
}

###############################################################################
# Outputs to be used in the RKE cluster provisioning
###############################################################################

output "aws_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "aws_security_group" {
  value = aws_security_group.rancher_sg_allow_all.name
}

output "aws_iam_profile_name" {
  value = aws_iam_instance_profile.iam-instance-profile.name
}
###############################################################################
# Network Infrastructure for Rancher Server and the RKE Cluster
###############################################################################

# Define the VPC
resource "aws_vpc" "vpc" {
  cidr_block           = module.common.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${module.common.prefix}-${module.common.domain_prefix}-vpc"
  }
}

# Deploy a Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(module.common.vpc_cidr, 4, 0)
  map_public_ip_on_launch = true
  availability_zone       = "${module.common.aws_region}${module.common.aws_az}"

  tags = {
    Name = "${module.common.prefix}-${module.common.domain_prefix}-public_subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  depends_on = [aws_subnet.public_subnet]
  vpc_id     = aws_vpc.vpc.id

  tags = {
    Name = "${module.common.prefix}-${module.common.domain_prefix}-igw"
  }
}

# Add the default route to the main route table
resource "aws_route" "internet_route" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# Security group to allow all traffic
resource "aws_security_group" "rancher_sg_allow_all" {
  name        = "${module.common.prefix}-${module.common.domain_prefix}-allow-all"
  description = "Rancher Workshop - allow all traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "${module.common.prefix}-${module.common.domain_prefix}-allow-all"
  }
}

###############################################################################
# TLS Keys Creation
###############################################################################

resource "tls_private_key" "global_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_sensitive_file" "ssh_private_key_pem" {
  filename        = "../common/id_rsa"
  content         = tls_private_key.global_key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "ssh_public_key_openssh" {
  filename = "../common/id_rsa.pub"
  content  = tls_private_key.global_key.public_key_openssh
}

# Temporary key pair used for SSH accesss
resource "aws_key_pair" "rancher_key_pair" {
  key_name_prefix = "${module.common.prefix}-${module.common.domain_prefix}-"
  public_key      = tls_private_key.global_key.public_key_openssh
}

###############################################################################
# Elastic IP for Rancher Server
###############################################################################

resource "aws_eip" "rancher_public_ip" {
  depends_on    = [aws_internet_gateway.internet_gateway]

  vpc = true

  instance                  = aws_instance.rancher_server.id
  associate_with_private_ip = "100.0.0.100"

  tags = {
    Name = "${module.common.prefix}-${module.common.domain_prefix}-elastic-ip"
  }
}


###############################################################################
# EC2 Instance for the Rancher Server
###############################################################################

# AWS EC2 instance for creating a single node K3S cluster and installing the Rancher server
resource "aws_instance" "rancher_server" {
  depends_on    = [aws_internet_gateway.internet_gateway]
  ami           = data.aws_ami.sles.id
  instance_type = module.common.instance_type
  subnet_id     = aws_subnet.public_subnet.id
  private_ip    = "100.0.0.100"

  key_name               = aws_key_pair.rancher_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.rancher_sg_allow_all.id]

  root_block_device {
    volume_size = 16
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = module.common.node_username
    private_key = tls_private_key.global_key.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Completed cloud-init!'",
    ]
  }

  tags = {
    Name = "${module.common.prefix}-${module.common.domain_prefix}-server"
  }
}

###############################################################################
# Load Balancer Creation
###############################################################################

resource "aws_lb" "rancher_lb" {
  depends_on         = [aws_internet_gateway.internet_gateway]
  name               = "${module.common.prefix}-${module.common.domain_prefix}-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public_subnet.id]

  enable_deletion_protection = false

  tags = {
    Name = "${module.common.prefix}-${module.common.domain_prefix}-lb"
  }
}

resource "aws_lb_listener" "rancher_front_end" {
  load_balancer_arn = aws_lb.rancher_lb.arn
  port              = "443"
  protocol          = "TLS"
  certificate_arn   = aws_acm_certificate.rancher_cert.arn
  alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rancher_tg.arn
  }

  tags = {
    Name = "${module.common.prefix}-${module.common.domain_prefix}-front-end"
  }
}

resource "aws_lb_target_group" "rancher_tg" {
  name     = "${module.common.prefix}-${module.common.domain_prefix}-tg"
  port     = 443
  protocol = "TLS"
  vpc_id   = aws_vpc.vpc.id

  tags = {
    Name = "${module.common.prefix}-${module.common.domain_prefix}-target-group"
  }

}

resource "aws_lb_target_group_attachment" "rancher_tga" {
  target_group_arn = aws_lb_target_group.rancher_tg.arn
  target_id        = aws_instance.rancher_server.id
}

###############################################################################
# Hosted Zone record and Certificate creation
###############################################################################

# Hosted Zone record Creation
resource "aws_route53_record" "rancher_record" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "${module.common.domain_prefix}.${module.common.hosted_zone}"
  type    = "A"

  alias {
    name                   = aws_lb.rancher_lb.dns_name
    zone_id                = aws_lb.rancher_lb.zone_id
    evaluate_target_health = true
  }
}

# Certificate creation
resource "aws_acm_certificate" "rancher_cert" {
  domain_name               = module.common.hosted_zone
  subject_alternative_names = [aws_route53_record.rancher_record.name]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${module.common.prefix}-${module.common.domain_prefix}-certificate"
  }

}

# Hosted Zone record for the Certificate creation
resource "aws_route53_record" "certificate_record" {
  for_each = {
    for dvo in aws_acm_certificate.rancher_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
}

# Certificate Validation
resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = aws_acm_certificate.rancher_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_record : record.fqdn]
}

###############################################################################
# IAM role for the Rancher server to provision the RKE's service Loadbalancers
###############################################################################

resource "aws_iam_role" "iam-role" {
  name               = "${module.common.prefix}-${module.common.domain_prefix}-role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json

  managed_policy_arns = [aws_iam_policy.cluster-policy.arn]
}

resource "aws_iam_instance_profile" "iam-instance-profile" {
  name = "${module.common.prefix}-${module.common.domain_prefix}-profile"
  role = aws_iam_role.iam-role.name
}

resource "aws_iam_policy" "cluster-policy" {
  name = "${module.common.prefix}-${module.common.domain_prefix}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVolumes",
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifyVolume",
          "ec2:AttachVolume",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:DeleteSecurityGroup",
          "ec2:DeleteVolume",
          "ec2:DetachVolume",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DescribeVpcs",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:BatchGetImage",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:AttachLoadBalancerToSubnets",
          "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateLoadBalancerPolicy",
          "elasticloadbalancing:CreateLoadBalancerListeners",
          "elasticloadbalancing:ConfigureHealthCheck",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancerListeners",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DetachLoadBalancerFromSubnets",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeLoadBalancerPolicies",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
          "iam:CreateServiceLinkedRole",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }
    ]
  })
}
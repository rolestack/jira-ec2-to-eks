provider "aws" {
  shared_credentials_files      = ["~/.aws/credentials"]
  profile                       = "rolestack"
  region                        = "ap-northeast-2"
}

# default-resource 연동
data "terraform_remote_state" "default-resource" {
  backend = "local"
  config = {
    path = "../default-resource/terraform.tfstate"
  }
}

# SG
resource "aws_security_group" "atlassian-node" {
  vpc_id = data.terraform_remote_state.default-resource.outputs.aws_vpc

  ingress = [{
    cidr_blocks                 = ["0.0.0.0/0"]
    description                 = "ssh"
    from_port                   = 22
    ipv6_cidr_blocks            = null
    prefix_list_ids             = null
    protocol                    = "tcp"
    security_groups             = null
    self                        = false
    to_port                     = 22
  },
  {
    cidr_blocks                 = ["0.0.0.0/0"]
    description                 = "HTTP"
    from_port                   = 80
    ipv6_cidr_blocks            = null
    prefix_list_ids             = null
    protocol                    = "tcp"
    security_groups             = null
    self                        = false
    to_port                     = 80
  },
  {
    cidr_blocks                 = ["0.0.0.0/0"]
    description                 = "HTTPS"
    from_port                   = 443
    ipv6_cidr_blocks            = null
    prefix_list_ids             = null
    protocol                    = "tcp"
    security_groups             = null
    self                        = false
    to_port                     = 443
  },
  {
    cidr_blocks                 = [data.terraform_remote_state.default-resource.outputs.vpc_cidr_block]
    description                 = "crowd"
    from_port                   = 8095
    ipv6_cidr_blocks            = null
    prefix_list_ids             = null
    protocol                    = "tcp"
    security_groups             = null
    self                        = false
    to_port                     = 8095
  },
  {
    cidr_blocks                 = [data.terraform_remote_state.default-resource.outputs.vpc_cidr_block]
    description                 = "postgresql"
    from_port                   = 5432
    ipv6_cidr_blocks            = null
    prefix_list_ids             = null
    protocol                    = "tcp"
    security_groups             = null
    self                        = false
    to_port                     = 5432
  },
  {
    cidr_blocks                 = [data.terraform_remote_state.default-resource.outputs.vpc_cidr_block]
    description                 = "nfs-1"
    from_port                   = 111
    ipv6_cidr_blocks            = null
    prefix_list_ids             = null
    protocol                    = "tcp"
    security_groups             = null
    self                        = false
    to_port                     = 111
  },
  {
    cidr_blocks                 = [data.terraform_remote_state.default-resource.outputs.vpc_cidr_block]
    description                 = "nfs-2"
    from_port                   = 2049
    ipv6_cidr_blocks            = null
    prefix_list_ids             = null
    protocol                    = "tcp"
    security_groups             = null
    self                        = false
    to_port                     = 2049
  },
  {
    cidr_blocks                 = [data.terraform_remote_state.default-resource.outputs.vpc_cidr_block]
    description                 = "confluence"
    from_port                   = 8090
    ipv6_cidr_blocks            = null
    prefix_list_ids             = null
    protocol                    = "tcp"
    security_groups             = null
    self                        = false
    to_port                     = 8090
  },
  {
    cidr_blocks                 = [data.terraform_remote_state.default-resource.outputs.vpc_cidr_block]
    description                 = "confluence synchrony"
    from_port                   = 8091
    ipv6_cidr_blocks            = null
    prefix_list_ids             = null
    protocol                    = "tcp"
    security_groups             = null
    self                        = false
    to_port                     = 8091
  },
  {
    cidr_blocks                 = [data.terraform_remote_state.default-resource.outputs.vpc_cidr_block]
    description                 = "confluence hazelcast(confluence)"
    from_port                   = 5801
    ipv6_cidr_blocks            = null
    prefix_list_ids             = null
    protocol                    = "tcp"
    security_groups             = null
    self                        = false
    to_port          = 5801
  },
  {
    cidr_blocks                 = [data.terraform_remote_state.default-resource.outputs.vpc_cidr_block]
    description                 = "confluence hazelcast(synchrony)"
    from_port                   = 5701
    ipv6_cidr_blocks            = null
    prefix_list_ids             = null
    protocol                    = "tcp"
    security_groups             = null
    self                        = false
    to_port                     = 5701
  },
  {
    cidr_blocks                 = [data.terraform_remote_state.default-resource.outputs.vpc_cidr_block]
    description                 = "confluence cluster base port"
    from_port                   = 25500
    ipv6_cidr_blocks            = null
    prefix_list_ids             = null
    protocol                    = "tcp"
    security_groups             = null
    self                        = false
    to_port                     = 25500
  },
  {
    cidr_blocks                 = [data.terraform_remote_state.default-resource.outputs.vpc_cidr_block]
    description                 = "jira"
    from_port                   = 8080
    ipv6_cidr_blocks            = null
    prefix_list_ids             = null
    protocol                    = "tcp"
    security_groups             = null
    self                        = false
    to_port                     = 8080
  },
  {
    cidr_blocks                 = [data.terraform_remote_state.default-resource.outputs.vpc_cidr_block]
    description                 = "jira ecache"
    from_port                   = 40001
    ipv6_cidr_blocks            = null
    prefix_list_ids             = null
    protocol                    = "tcp"
    security_groups             = null
    self                        = false
    to_port                     = 40001
  },
  {
    cidr_blocks                 = [data.terraform_remote_state.default-resource.outputs.vpc_cidr_block]
    description                 = "confluence"
    from_port                   = 40011
    ipv6_cidr_blocks            = null
    prefix_list_ids             = null
    protocol                    = "tcp"
    security_groups             = null
    self                        = false
    to_port                     = 40011
  }]

  egress = [{
    cidr_blocks                 = ["0.0.0.0/0"]
    description                 = "internet"
    from_port                   = 0
    ipv6_cidr_blocks            = null
    prefix_list_ids             = null
    protocol                    = "-1"
    security_groups             = null
    self                        = false
    to_port                     = 0
  }]
  tags = {
    "Create by" = "rolestack"
    "Terraform"   = "true"
    "Name"      = "[rolestack] Atlassian Node SG"
  }
}


locals {
  # 서브넷 CIDR 블록 가져오기
  subnet_cidrs = [for subnet in data.terraform_remote_state.default-resource.outputs.public_subnet : subnet.cidr_block]

  # 각 서브넷에 대해 IP 주소 할당 (각 서브넷의 첫 번째 주소를 사용)
  private_ips = [for subnet in local.subnet_cidrs : cidrhost(subnet, 10)]
}

# 로컬 키 등록
resource "aws_key_pair" "key_pair" {
  key_name   = "rolestack-key"
  public_key = file("~/.ssh/rolestack.public")

  tags = {
    "Name"      = "rolestack-key"
    "Create by" = "rolestack"
    "Terraform" = "true"
  }
}

# EC2
resource "aws_instance" "jira-node" {
  # count                         = length(var.private-subnets)
  count                           = 2
  ami                             = var.atlassian-node["ami"]
  instance_type                   = var.atlassian-node["instance_type"]
  subnet_id                       = data.terraform_remote_state.default-resource.outputs.public_subnet_ids[count.index]
  key_name                        = aws_key_pair.key_pair.key_name
  private_ip                      = local.private_ips[count.index]
  vpc_security_group_ids          = [aws_security_group.atlassian-node.id]
  root_block_device {
    volume_size                   = var.atlassian-node["root-volume-size"]
    volume_type                   = var.atlassian-node["root-volume-type"]
    delete_on_termination         = false
    encrypted                     = true # Root volume encryption for mount dynamic provisioning ebs volume
    tags = {
      "Name"                      = "[rolestack] Jira migration root volume-${count.index}"
      "Create by"                 = "rolestack"
      "Terraform"                 = "true"
    }
  }

  tags = {
    "Name"                        = "[rolestack] Jira migration instance-${count.index}"
    "Create by"                   = "rolestack"
    "Terraform"                   = "true"
  }
}

# EBS Attach for Jira home directory
resource "aws_volume_attachment" "jira-node-attachment" {
  count                           = length(aws_instance.jira-node)
  device_name                     = "/dev/sdf"
  instance_id                     = aws_instance.jira-node[count.index].id
  volume_id                       = aws_ebs_volume.jira-node-attachment[count.index].id
  force_detach                    = true
}

# EBS for Jira home directory
resource "aws_ebs_volume" "jira-node-attachment" {
  count                           = length(aws_instance.jira-node)
  availability_zone               = data.terraform_remote_state.default-resource.outputs.public_subnet_azs[count.index]
  size                            = var.atlassian-node["additional-volume-size"]
  type                            = var.atlassian-node["additional-volume-type"]
  tags = {
    "Name"                        = "[rolestack] Jira migration additional volume-${count.index}"
    "Create by"                   = "rolestack"
    "Terraform"                   = "true"
  }
}

resource "aws_ec2_instance_state" "jira-node" {
  count       = length(aws_instance.jira-node)
  instance_id = aws_instance.jira-node[count.index].id
  # stopped, running
  state       = "running"
}

resource "aws_eip" "jira_node_eip" {
  count = length(aws_instance.jira-node)

  tags = {
    "Create by" = "rolestack"
    Terraform   = "true"
  }
}

resource "aws_eip_association" "jira_node_eip_assoc" {
  count          = length(aws_instance.jira-node)
  instance_id    = aws_instance.jira-node[count.index].id
  allocation_id  = aws_eip.jira_node_eip[count.index].id
}
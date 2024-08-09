provider "aws" {
  shared_credentials_files        = ["~/.aws/credentials"]
  profile                         = "rolestack"
  region                          = "ap-northeast-2"
}

# default-resource 연동
data "terraform_remote_state" "default-resource" {
  backend                         = "local"
  config                          = {
    path                          = "../default-resource/terraform.tfstate"
  }
}

resource "aws_db_subnet_group" "default" {
  name                            = "rolestack-jira-migration-test-rds-subnet-group"
  subnet_ids                      = data.terraform_remote_state.default-resource.outputs.private_subnet_ids

  tags = {
      "Name"                      = "rolestack-jira-migration-test-rds-subnet-group"
      "Create by"                 = "rolestack"
      "Terraform"                 = "true"
    }
}

resource "aws_db_instance" "default" {
  allocated_storage               = 20
  engine                          = "mysql"
  engine_version                  = "8.0"
  instance_class                  = "db.t3.medium"
  username                        = "admin"
  password                        = var.db_password
  parameter_group_name            = "default.mysql8.0"
  skip_final_snapshot             = true
  multi_az                        = false
  availability_zone               = data.terraform_remote_state.default-resource.outputs.private_subnet_azs[0]
  vpc_security_group_ids          = [aws_security_group.rds_sg.id]

  db_subnet_group_name = aws_db_subnet_group.default.name

  tags = {
      "Name"                      = "rolestack-jira-migration-test-rds"
      "Create by"                 = "rolestack"
      "Terraform"                 = "true"
    }
}

resource "aws_security_group" "rds_sg" {
  name        = "rolestack-jira-migration-test-rds-sg"
  description = "Allow MySQL traffic"
  vpc_id      = data.terraform_remote_state.default-resource.outputs.aws_vpc

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.default-resource.outputs.vpc_cidr_block]  # 필요한 경우 제한된 CIDR 블록을 사용하여 보안을 강화
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "rolestack-jira-migration-test-rds-sg"
    "Create by" = "rolestack"
    "Terraform" = "true"
  }
}

# EFS 설정
resource "aws_efs_file_system" "default" {
  creation_token                  = "rolestack-jira-migration-test-efs"
  lifecycle_policy {
    transition_to_ia              = "AFTER_180_DAYS"
  }

  tags = {
      "Name"                      = "rolestack-jira-migration-test-efs"
      "Create by"                 = "rolestack"
      "Terraform"                 = "true"
    }
}

resource "aws_efs_mount_target" "default" {
  for_each                        = toset(data.terraform_remote_state.default-resource.outputs.private_subnet_ids)
  file_system_id                  = aws_efs_file_system.default.id
  subnet_id                       = each.value
  security_groups                 = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name                            = "[rolestack] migration test efs sg"
  description                     = "EFS security group"
  vpc_id                          = data.terraform_remote_state.default-resource.outputs.aws_vpc

  ingress {
    from_port                     = 2049
    to_port                       = 2049
    protocol                      = "tcp"
    cidr_blocks                   = [data.terraform_remote_state.default-resource.outputs.vpc_cidr_block]
  }

  egress {
    from_port                     = 0
    to_port                       = 0
    protocol                      = "-1"
    cidr_blocks                   = [data.terraform_remote_state.default-resource.outputs.vpc_cidr_block]
  }

  tags = {
      "Name"                      = "[rolestack] migration test efs sg"
      "Create by"                 = "rolestack"
      "Terraform"                 = "true"
    }
}
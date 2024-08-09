provider "aws" {
  shared_credentials_files      = ["~/.aws/credentials"]
  profile                       = "rolestack"
  region                        = "ap-northeast-2"
}

# Default 리소스 연동
data "terraform_remote_state" "default-resource" {
  backend = "local"
  config = {
    path = "../default-resource/terraform.tfstate"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "rolestack_test"
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    aws-efs-csi-driver     = {}
    aws-ebs-csi-driver     = {}
  }

  vpc_id                   = data.terraform_remote_state.default-resource.outputs.aws_vpc
  # Private 서브넷 사용
  subnet_ids               = data.terraform_remote_state.default-resource.outputs.private_subnet_ids
  # ap-northeast-2a, 2c 사용
  control_plane_subnet_ids = slice(data.terraform_remote_state.default-resource.outputs.private_subnet_ids, 0, 2)

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m5.large"]
  }

  eks_managed_node_groups = {
    sa2-eks_worker-group = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.large"]

      desired_size = 2
      min_size     = 2
      max_size     = 4
      
    }

  }

  # Cluster 접근 사용자 정의
  enable_cluster_creator_admin_permissions = true

# 아래 항목을 주석 해제하면 Terraform 실행 사용자가 아닌 별도 사용자에게 관리자 권한 할당 가능
#   access_entries = {
#     # One access entry with a policy associated
#     sa2-eks_access-entries = {
#       kubernetes_groups = []
#       # 현재 사용자가 아닌 별도 EKS 클러스터 관리자 권한 할당 / 현재 사용자로 동작하면 에러 발생
#       # principal_arn     = <data.aws_caller_identity.current.arn or static ARN>

#       policy_associations = {
#         example = {
#           policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
#           access_scope = {
#             namespaces = ["default"]
#             type       = "namespace"
#           }
#         }
#       }
#     }
#   }

  tags = {
    "Create by" = "rolestack"
    Environment = "dev"
    Terraform   = "true"
  }
}


# Ingress-Controller Policy Attachment
resource "aws_iam_role_policy" "worker_alb_policy" {
  name   = "eks-worker-alb-policy"
  role  = module.eks.eks_managed_node_groups.sa2-eks_worker-group.iam_role_name
  policy = data.http.alb_policy.response_body
}

# Use AWS-ALB-Ingress-Controller Policy
data "http" "alb_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.8.1/docs/install/iam_policy.json"

  request_headers = {
    Accept = "application/json"
  }
}

# EBS CSI Driver Policy Attachment
resource "aws_iam_role_policy" "worker_ebs_policy" {
  name   = "eks-worker-ebs-policy"
  role  = module.eks.eks_managed_node_groups.sa2-eks_worker-group.iam_role_name
  policy = data.http.ebs_policy.response_body
}

# Use EBS CSI Driver Policy
data "http" "ebs_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/docs/example-iam-policy.json"

  request_headers = {
    Accept = "application/json"
  }
}
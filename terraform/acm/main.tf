provider "aws" {
  shared_credentials_files      = ["~/.aws/credentials"]
  profile                       = "rolestack"
  region                        = "ap-northeast-2"
}

# 외부 인증서 등록
resource "aws_acm_certificate" "zlcus-com" {
  private_key                   = file("./cert/zlcus-key.pem")
  certificate_body              = file("./cert/zlcus-ca.pem")

  tags = {
    "Create by"                 = "rolestack"
    "Environment"               = "dev"
    "Terraform"                 = "true"
  }
}
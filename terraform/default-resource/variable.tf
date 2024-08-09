variable "vpc" {
    type                    = map(string)
    default = {
        "vpc-name"           = "[rolestack] VPC"
        "vpc-cidr"           = "10.1.0.0/16"
    }
}

variable "public-subnet-names" {
    type                    = list(string)
    default = [
        "[rolestack] 2a-public",
        "[rolestack] 2b-public",
        "[rolestack] 2c-public",
        "[rolestack] 2d-public"
    ]
}

variable "private-subnet-names" {
    type                    = list(string)
    default = [
        "[rolestack] 2a-private",
        "[rolestack] 2b-private",
        "[rolestack] 2c-private",
        "[rolestack] 2d-private"
    ]
}

variable "azs" {
    type                    = list(string)
    default = [
        "ap-northeast-2a",
        "ap-northeast-2b",
        "ap-northeast-2c",
        "ap-northeast-2d"
    ]
}

variable "igw" {
    type                    = map(string)
    default = {
      "Name"                = "[rolestack] IGW"
    }
}

variable "eip" {
    type                    = map(string)
    default = {
        "Name"              = "[rolestack] NATGW-EIP"
    }
}

variable "ngw" {
    type                    = map(string)
    default = {
      "Name"                = "[rolestack] NATGW"
    }
}

variable "route-table" {
    type                    = map(string)
    default = {
        "public-name"       = "[rolestack] Public-rtb"
        "private-name"      = "[rolestack] Private-rtb"
    }
}


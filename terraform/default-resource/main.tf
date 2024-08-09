provider "aws" {
  shared_credentials_files      = ["~/.aws/credentials"]
  profile                       = "rolestack"
  region                        = "ap-northeast-2"
}


# VPC
resource "aws_vpc" "vpc" {
  cidr_block                    = var.vpc["vpc-cidr"]
  instance_tenancy              = "default"
  enable_dns_support            = true
  enable_dns_hostnames          = true
  tags = {
    Name                        = var.vpc["vpc-name"]
    "Create by"                 = "rolestack"
    }
}


# Subnet
resource "aws_subnet" "public" {
  count                         = length(var.azs)
  vpc_id                        = aws_vpc.vpc.id
  cidr_block                    = "10.1.${count.index}.0/24"
  availability_zone             = var.azs[count.index]
  tags = {
     Name                       = var.public-subnet-names[count.index]
     Tier                       = "Public"
     "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private" {
  count                         = length(var.azs)
  vpc_id                        = aws_vpc.vpc.id
  cidr_block                    = "10.1.${count.index+128}.0/24"
  availability_zone             = var.azs[count.index]
  tags = {
     Name                       = var.private-subnet-names[count.index]
     Tier                       = "Private"
  }
}

# EIP for NGW
resource "aws_eip" "ngw" {
  domain                        = "vpc"
  depends_on                    = [aws_internet_gateway.igw]
  tags = {
    Name                        = var.eip["Name"]
  }
}


# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id                        = aws_vpc.vpc.id
  tags = {
    Name                        = var.igw["Name"]
  }
}


# NGW
resource "aws_nat_gateway" "ngw" {
  allocation_id                 = aws_eip.ngw.id
  subnet_id                     = aws_subnet.public[0].id
  tags = {
    Name                        = var.ngw["Name"]
  }
}


# Route Table
resource "aws_route_table" "public" {
  vpc_id                        = aws_vpc.vpc.id
  route = [{
    cidr_block                  = "0.0.0.0/0",
    gateway_id                  = aws_internet_gateway.igw.id
    carrier_gateway_id          = null
    destination_prefix_list_id  = null
    egress_only_gateway_id      = null
    instance_id                 = null
    ipv6_cidr_block             = null
    local_gateway_id            = null
    nat_gateway_id              = null
    network_interface_id        = null
    transit_gateway_id          = null
    vpc_endpoint_id             = null
    vpc_peering_connection_id   = null
    core_network_arn            = null       
  }]
  tags = {
    Name                        = var.route-table["public-name"]
  }
}

resource "aws_route_table" "private" {
  vpc_id                        = aws_vpc.vpc.id
  route = [{
    cidr_block                  = "0.0.0.0/0"
    gateway_id                  = aws_nat_gateway.ngw.id
    carrier_gateway_id          = null
    destination_prefix_list_id  = null
    egress_only_gateway_id      = null
    instance_id                 = null
    ipv6_cidr_block             = null
    local_gateway_id            = null
    nat_gateway_id              = null
    network_interface_id        = null
    transit_gateway_id          = null
    vpc_endpoint_id             = null
    vpc_peering_connection_id   = null
    core_network_arn            = null
  }]
  tags = {
    Name                        = var.route-table["public-name"]
  }
}

resource "aws_route_table_association" "public-subnet-association" {
  count                         = length(aws_subnet.public)
  subnet_id                     = aws_subnet.public[count.index].id
  route_table_id                = aws_route_table.public.id  
}

resource "aws_route_table_association" "private-subnet-association" {
  count                         = length(aws_subnet.private)
  subnet_id                     = aws_subnet.private[count.index].id
  route_table_id                = aws_route_table.private.id
}
output "aws_vpc" {
    value               = resource.aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnet" {
  value                 = aws_subnet.public
}

output "private_subnet" {
  value                 = aws_subnet.private
}

output "public_subnet_ids" {
  value                 = aws_subnet.public[*].id
}

output "public_subnet_azs" {
  value = aws_subnet.public[*].availability_zone
}

output "private_subnet_ids" {
  value                 = aws_subnet.private[*].id
}

output "private_subnet_azs" {
  value = aws_subnet.private[*].availability_zone
}

output "nat_gateway_id" {
  value                 = aws_nat_gateway.ngw.id
}
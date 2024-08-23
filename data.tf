# Data block to fetch VPC CIDR block
data "aws_vpc" "target_vpc" {
  id = var.target_vpc_id
}

data "aws_vpc" "source_vpc" {
  id = var.source_vpc_id
}

data "aws_ec2_transit_gateway" "this" {
  id = var.existing_transit_gateway_id
}

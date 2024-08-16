terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      version = "~> 4.0"
      source  = "hashicorp/aws"
    }

    awsutils = {
      source  = "cloudposse/awsutils"
      version = "~> 0.15"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "awsutils" {
  region = var.region
}

provider "aws" {
  alias  = "target"
  region = var.region
  assume_role {
    role_arn = var.assume_role_arn
  }
}

##################### Source Account #################
# Existing Transit Gateway in the source account
resource "aws_ec2_transit_gateway" "transit_gateway" {
  provider                        = aws
  amazon_side_asn                 = var.transit_gateway_asn
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name = var.transit_gateway_name
  }
}

# Sharing the Transit Gateway via RAM
resource "aws_ram_resource_share" "transit_gateway_share" {
  name                      = "transit-gateway-share"
  allow_external_principals = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ram_principal_association" "target_account" {
  resource_share_arn = aws_ram_resource_share.transit_gateway_share.arn
  principal          = var.target_account_id
}

resource "aws_ram_resource_association" "transit_gateway" {
  resource_share_arn = aws_ram_resource_share.transit_gateway_share.arn
  resource_arn       = aws_ec2_transit_gateway.transit_gateway.arn
}


resource "aws_ec2_transit_gateway_vpc_attachment" "source" {

  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  vpc_id             = var.source_vpc_id

  subnet_ids = var.source_subnet_ids

  dns_support  = "enable"
  ipv6_support = "disable"

  tags = {
    Name = "TransitGateway-VPC-Attachment"
  }
  depends_on = [aws_ec2_transit_gateway.transit_gateway]
}

resource "aws_route" "source" {
  for_each               = toset(var.source_route_table_ids)
  route_table_id         = each.value
  destination_cidr_block = var.destination_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.transit_gateway.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.source]
}


################### Target Acconunt #####################################
# Accept the share in the target account
#########################################################################
resource "aws_ram_resource_share_accepter" "transit_gateway" {
  provider  = aws.target
  share_arn = aws_ram_resource_share.transit_gateway_share.arn

  depends_on = [aws_ram_principal_association.target_account]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  provider           = aws.target
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  vpc_id             = var.vpc_id

  subnet_ids = var.subnet_ids

  dns_support  = "enable"
  ipv6_support = "disable"

  tags = {
    Name = "TransitGateway-VPC-Attachment"
  }
  depends_on = [aws_ec2_transit_gateway.transit_gateway]
}

resource "aws_route" "this" {
  provider               = aws.target
  for_each               = toset(var.route_table_ids)
  route_table_id         = each.value
  destination_cidr_block = var.source_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.transit_gateway.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.this]
}

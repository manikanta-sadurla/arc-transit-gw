terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      version = "~> 4.0"
      source  = "hashicorp/aws"
      configuration_aliases = [aws.target]
    }

    awsutils = {
      source  = "cloudposse/awsutils"
      version = "~> 0.15"
    }
  }
}

# provider "aws" {
#   region = var.region
# }

# provider "awsutils" {
#   region = var.region
# }

# provider "aws" {
#   alias  = "target"
#   region = var.region
#   assume_role {
#     role_arn = var.assume_role_arn
#   }
# }


# Conditional creation of Transit Gateway
resource "aws_ec2_transit_gateway" "transit_gateway" {
  count                           = var.create_transit_gateway ? 1 : 0
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

# Share the Transit Gateway via RAM
resource "aws_ram_resource_share" "transit_gateway_share" {
  name                      = "transit-gateway-share"
  allow_external_principals = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ram_principal_association" "target_account" {
  for_each               = toset(var.target_account_id)
  resource_share_arn = aws_ram_resource_share.transit_gateway_share.arn
  principal          = each.value
}

resource "aws_ram_resource_association" "transit_gateway" {
  resource_share_arn = aws_ram_resource_share.transit_gateway_share.arn
  resource_arn       = var.create_transit_gateway ? aws_ec2_transit_gateway.transit_gateway[0].arn : var.existing_transit_gateway_arn
}

resource "aws_ec2_transit_gateway_vpc_attachment" "source" {
  transit_gateway_id = var.create_transit_gateway ? aws_ec2_transit_gateway.transit_gateway[0].id : var.existing_transit_gateway_id
  vpc_id             = var.source_vpc_id
  subnet_ids         = var.source_subnet_ids
  dns_support        = "enable"
  ipv6_support       = "disable"

  tags = {
    Name = "TransitGateway-VPC-Attachment"
  }

  depends_on = [
    aws_ec2_transit_gateway.transit_gateway,
    aws_ram_principal_association.target_account,
    aws_ram_resource_association.transit_gateway
  ]
}


resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "source" {
  count                         = var.create_transit_gateway ? 0 : 1
#   provider                      = aws
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.this.id
}

resource "aws_route" "source" {
  for_each               = toset(var.source_route_table_ids)
  route_table_id         = each.value
  destination_cidr_block = var.destination_cidr_block
  transit_gateway_id     = var.create_transit_gateway ? aws_ec2_transit_gateway.transit_gateway[0].id : var.existing_transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.source]
}

####################################################################
# Target Account resources
resource "aws_ram_resource_share_accepter" "transit_gateway" {
  provider  = aws.target
  share_arn = aws_ram_resource_share.transit_gateway_share.arn

  depends_on = [aws_ram_principal_association.target_account]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  provider           = aws.target
  transit_gateway_id = var.create_transit_gateway ? aws_ec2_transit_gateway.transit_gateway[0].id : var.existing_transit_gateway_id
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  dns_support        = "enable"
  ipv6_support       = "disable"

  tags = {
    Name = "TransitGateway-VPC-Attachment"
  }

  depends_on = [
    aws_ec2_transit_gateway.transit_gateway,
    aws_ram_principal_association.target_account,
    aws_ram_resource_association.transit_gateway
  ]
}


resource "aws_route" "this" {
  provider               = aws.target
  for_each               = toset(var.route_table_ids)
  route_table_id         = each.value
  destination_cidr_block = var.source_cidr_block
  transit_gateway_id     = var.create_transit_gateway ? aws_ec2_transit_gateway.transit_gateway[0].id : var.existing_transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.this]
}

# Conditional creation of Transit Gateway
resource "aws_ec2_transit_gateway" "this" {
  count                           = var.create_transit_gateway ? 1 : 0
  amazon_side_asn                 = var.transit_gateway_asn
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = var.dns_support
  vpn_ecmp_support                = var.vpn_ecmp_support

  tags = {
    Name = var.transit_gateway_name
  }
}

# Share the Transit Gateway via RAM
resource "aws_ram_resource_share" "transit_gateway_share" {
  name                      = var.transit_gateway_share_name
  allow_external_principals = var.allow_external_principals

  lifecycle {
    create_before_destroy = var.create_before_destroy
  }
}

resource "aws_ram_principal_association" "target_account" {
  for_each           = toset(var.target_account_id)
  resource_share_arn = aws_ram_resource_share.transit_gateway_share.arn
  principal          = each.value
}

resource "aws_ram_resource_association" "transit_gateway" {
  resource_share_arn = aws_ram_resource_share.transit_gateway_share.arn
  # resource_arn       = var.create_transit_gateway ? aws_ec2_transit_gateway.this[0].arn : var.existing_transit_gateway_arn
  resource_arn = var.create_transit_gateway ? aws_ec2_transit_gateway.this[0].arn : data.aws_ec2_transit_gateway.this.arn
}


# Conditionally create the Transit Gateway VPC Attachment for Source
resource "aws_ec2_transit_gateway_vpc_attachment" "source" {
  count = var.create_transit_gateway_attacment_source ? 1 : 0

  transit_gateway_id = var.create_transit_gateway ? aws_ec2_transit_gateway.this[0].id : var.existing_transit_gateway_id
  vpc_id             = var.source_vpc_id
  subnet_ids         = var.source_subnet_ids
  dns_support        = var.source_attachment_dns_support
  ipv6_support       = var.source_attachment_ipv6_support

  tags = {
    Name = "TransitGateway-VPC-Attachment-Source"
  }

  depends_on = [
    aws_ec2_transit_gateway.this,
    aws_ram_principal_association.target_account,
    aws_ram_resource_association.transit_gateway
  ]
}


resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "this" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.this.id
}

resource "aws_route" "source" {
  for_each       = toset(var.source_route_table_ids)
  route_table_id = each.value
  # destination_cidr_block = var.destination_cidr_block
  # destination_cidr_block = data.aws_vpc.target_vpc.cidr_block
  destination_cidr_block = var.target_cidr_block != null ? var.target_cidr_block : data.aws_vpc.source_vpc.cidr_block
  transit_gateway_id     = var.create_transit_gateway ? aws_ec2_transit_gateway.this[0].id : var.existing_transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.this]
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
  transit_gateway_id = var.create_transit_gateway ? aws_ec2_transit_gateway.this[0].id : var.existing_transit_gateway_id
  vpc_id             = var.target_vpc_id
  subnet_ids         = var.target_subnet_ids
  dns_support        = var.target_attachment_dns_support
  ipv6_support       = var.target_attachment_ipv6_support

  tags = {
    Name = "TransitGateway-VPC-Attachment"
  }

  depends_on = [
    aws_ec2_transit_gateway.this,
    aws_ram_principal_association.target_account,
    aws_ram_resource_association.transit_gateway
  ]
}


resource "aws_route" "this" {
  provider       = aws.target
  for_each       = toset(var.target_route_table_ids)
  route_table_id = each.value
  # destination_cidr_block = var.source_cidr_block
  destination_cidr_block = var.source_cidr_block != null ? var.source_cidr_block : data.aws_vpc.source_vpc.cidr_block
  transit_gateway_id     = var.create_transit_gateway ? aws_ec2_transit_gateway.this[0].id : var.existing_transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.this]
}

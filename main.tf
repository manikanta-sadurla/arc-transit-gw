# modules/transit_gateway/main.tf
resource "aws_ec2_transit_gateway" "this" {
  description = "My Transit Gateway"
  // Add any other required configurations
}

resource "aws_ram_resource_share" "this" {
  name                      = "MyTransitGatewayShare"
  allow_external_principals = false
  tags = {
    Name = "MyTransitGatewayShare"
  }
}

resource "aws_ram_principal_association" "principal_association" {
  for_each = toset(var.account_ids)
  
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.this.arn
}

output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.this.id
}

output "transit_gateway_arn" {
  value = aws_ec2_transit_gateway.this.arn
}

output "resource_share_arn" {
  value = aws_ram_resource_share.this.arn
}


#Module for Accepting the RAM Share in Destination Accounts

# modules/ram_share_accepter/main.tf
data "aws_caller_identity" "current" {}

resource "aws_ram_resource_share_accepter" "this" {
  provider = aws.destination
  
  # share_arn = var.resource_share_arn
  share_arn = aws_ram_resource_share.this.arn
}

output "resource_share_arn" {
  value = aws_ram_resource_share_accepter.this.share_arn
}



#Module for Attaching Transit Gateway and Routing

# modules/transit_gateway_attachment/main.tf
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id

  tags = {
    Name = "My TGW Attachment"
  }
}

resource "aws_ec2_transit_gateway_route_table" "this" {
  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name = "My TGW Route Table"
  }
}

resource "aws_ec2_transit_gateway_route" "route" {
  count                  = length(var.route_table_associations)
  destination_cidr_block = element(var.route_table_associations, count.index)
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
}

output "transit_gateway_vpc_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.this.id
}

output "transit_gateway_route_table_id" {
  value = aws_ec2_transit_gateway_route_table.this.id
}

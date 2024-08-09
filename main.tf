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
  # Uncomment and configure this if needed
  # assume_role {
  #   role_arn = local.environment_role[var.environment]
  # }
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
  provider                         = aws
  amazon_side_asn                  = var.transit_gateway_asn
  auto_accept_shared_attachments   = "enable"
  default_route_table_association  = "enable"
  default_route_table_propagation  = "enable"
  dns_support                      = "enable"
  vpn_ecmp_support                 = "enable"

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

################### Target Acconunt #####################################
# Accept the share in the target account
#########################################################################
resource "aws_ram_resource_share_accepter" "transit_gateway" {
  provider  = aws.target
  share_arn = aws_ram_resource_share.transit_gateway_share.arn

  depends_on = [aws_ram_principal_association.target_account]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "example" {
  provider           = aws.target
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  vpc_id             = var.vpc_id

  subnet_ids = var.subnet_ids

  dns_support = "enable"
  ipv6_support = "disable"

  tags = {
    Name = "TransitGateway-VPC-Attachment"
  }
}

resource "aws_route" "example" {
  provider            = aws.target
  route_table_id      = var.route_table_id
  destination_cidr_block = var.destination_cidr_block
  transit_gateway_id  = aws_ec2_transit_gateway.transit_gateway.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.example]
}





# ################################################################
# ## defaults
# ################################################################
# terraform {
#   required_version = "~> 1.3"

#   required_providers {
#     aws = {
#       version = "~> 4.0"
#       source  = "hashicorp/aws"
#     }

#     awsutils = {
#       source  = "cloudposse/awsutils"
#       version = "~> 0.15"
#     }
#   }
# }

# provider "aws" {
#   region = "us-east-1"
# }

# provider "awsutils" {
#   region = var.region
#   # Uncomment and configure this if needed
#   # assume_role {
#   #   role_arn = local.environment_role[var.environment]
#   # }
# }

# provider "aws" {
#   alias  = "target"
#   region = "us-east-1"
#   assume_role {
#     role_arn = "arn:aws:iam::654654163064:role/arc-destination-role"
#   }
# }

# # Existing Transit Gateway in the source account
# resource "aws_ec2_transit_gateway" "transit_gateway" {
#   provider                         = aws  # Using the default provider configuration
#   amazon_side_asn                  = 64512
#   auto_accept_shared_attachments   = "enable"
#   default_route_table_association  = "enable"
#   default_route_table_propagation  = "enable"
#   dns_support                      = "enable"
#   vpn_ecmp_support                 = "enable"

#   tags = {
#     Name = "Log-Archive-Transit-GW"
#   }
# }

# # Sharing the Transit Gateway via RAM
# resource "aws_ram_resource_share" "transit_gateway_share" {
#   name                      = "transit-gateway-share"
#   allow_external_principals = true  # Allow sharing with any AWS account

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_ram_principal_association" "target_account" {
#   resource_share_arn = aws_ram_resource_share.transit_gateway_share.arn
#   principal          = "654654163064"  # Target AWS Account ID
# }

# resource "aws_ram_resource_association" "transit_gateway" {
#   resource_share_arn = aws_ram_resource_share.transit_gateway_share.arn
#   resource_arn       = aws_ec2_transit_gateway.transit_gateway.arn
# }

# # Accept the share in the target account
# resource "aws_ram_resource_share_accepter" "transit_gateway" {
#   provider  = aws.target
#   share_arn = aws_ram_resource_share.transit_gateway_share.arn

#   depends_on = [aws_ram_principal_association.target_account]
# }



# resource "aws_ec2_transit_gateway_vpc_attachment" "example" {
#   provider = aws.target  # Use the target provider configuration
#   transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id  # Replace with the shared Transit Gateway ID
#   vpc_id = "vpc-04b82dc8a034d7004"  # The VPC ID

#   subnet_ids = [
#     "subnet-050501c4bb21ce041",
#     "subnet-0e36d58a2c71f52d7"
#   ]

#     dns_support = "enable"  # Enable DNS support
#     ipv6_support = "disable"  # Change to "enable" if IPv6 support is needed


#   tags = {
#     Name = "TransitGateway-VPC-Attachment"
#   }
# }


# resource "aws_route" "example" {
#   provider = aws.target  # Use the target provider configuration
#   route_table_id = "rtb-0727aefad8008b632"  # Replace with your route table ID
#   destination_cidr_block = "10.1.0.0/22"  # Replace with the Destination CIDR block of your VPC
#   transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id  # Replace with the shared Transit Gateway ID

#   depends_on = [aws_ec2_transit_gateway_vpc_attachment.example]  # Ensure the attachment is created before updating the route
# }
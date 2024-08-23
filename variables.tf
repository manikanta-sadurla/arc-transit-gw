################################################################
## variables
################################################################

variable "region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "transit_gateway_name" {
  description = "Name of the Transit Gateway"
  type        = string
  default     = "Log-Archive-Transit-GW"
}

variable "transit_gateway_asn" {
  description = "Amazon side ASN for the Transit Gateway"
  type        = number
  default     = 64512
}

variable "transit_gateway_share_name" {
  description = "The name of the Transit Gateway resource share."
  type        = string
  default     = "transit-gateway-share"
}

variable "allow_external_principals" {
  description = "Indicates whether external principals (accounts outside the organization) are allowed."
  type        = bool
  default     = true
}

variable "create_before_destroy" {
  description = "Determines whether the resource should be created before being destroyed."
  type        = bool
  default     = true
}


variable "auto_accept_shared_attachments" {
  description = "Whether resource attachment requests are automatically accepted"
  type        = string
  default     = "disable"
}

variable "default_route_table_association" {
  description = "Whether resource attachments are associated with the default route table"
  type        = string
  default     = "enable"
}

variable "default_route_table_propagation" {
  description = "Whether resource attachments automatically propagate routes to the default route table"
  type        = string
  default     = "enable"
}

variable "dns_support" {
  description = "Enable or disable DNS support"
  type        = string
  default     = "enable"
}

variable "vpn_ecmp_support" {
  description = "Enable or disable Equal Cost Multipath support for VPN"
  type        = string
  default     = "enable"
}

variable "source_attachment_dns_support" {
  description = "Enable or disable DNS support"
  type        = string
  default     = "enable"
}

variable "source_attachment_ipv6_support" {
  description = "Enable or disable IPv6 support"
  type        = string
  default     = "disable"
}


##############################################################
###################### Target Account ########################

variable "target_attachment_dns_support" {
  description = "Enable or disable DNS support"
  type        = string
  default     = "enable"
}

variable "target_attachment_ipv6_support" {
  description = "Enable or disable IPv6 support"
  type        = string
  default     = "disable"
}

variable "target_vpc_id" {
  description = "The VPC ID for the Transit Gateway VPC attachment"
  type        = string
}

variable "target_subnet_ids" {
  description = "List of subnet IDs for the Transit Gateway VPC attachment"
  type        = list(string)
}

variable "target_route_table_ids" {
  description = "Route table ID to add routes to"
  type        = list(any)
}

variable "source_cidr_block" {
  description = "Destination CIDR block for the route"
  type        = string
  default     = null
}

variable "target_account_id" {
  description = "The AWS Account ID where the Transit Gateway is shared"
  type        = list(any)
}



##############################################################
###################### Source Account ########################

variable "source_vpc_id" {
  description = "The VPC ID for the Transit Gateway VPC attachment"
  type        = string
  default     = null
}

variable "source_subnet_ids" {
  description = "List of subnet IDs for the Transit Gateway VPC attachment"
  type        = list(string)
  default     = []
}

variable "source_route_table_ids" {
  description = "Route table ID to add routes to"
  type        = list(any)
  default     = []
}

variable "target_cidr_block" {
  description = "Destination CIDR block for the route"
  type        = string
  default     = null
}
#######################################################################

variable "create_transit_gateway" {
  type    = bool
  default = true
}

# variable "existing_transit_gateway_arn" {
#   type    = string
#   default = null
# }

variable "existing_transit_gateway_id" {
  type    = string
  default = null
}


variable "create_transit_gateway_attacment_source" {
  type    = bool
  default = true
}

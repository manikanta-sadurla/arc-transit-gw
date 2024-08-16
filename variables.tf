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

##############################################################
###################### Target Account ########################
variable "vpc_id" {
  description = "The VPC ID for the Transit Gateway VPC attachment"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Transit Gateway VPC attachment"
  type        = list(string)
}

variable "route_table_ids" {
  description = "Route table ID to add routes to"
  type        = list(any)
}

variable "source_cidr_block" {
  description = "Destination CIDR block for the route"
  type        = string
}

variable "target_account_id" {
  description = "The AWS Account ID where the Transit Gateway is shared"
  type        = string
}

variable "assume_role_arn" {
  description = "ARN of the role to assume in the target account"
  type        = string
}


##############################################################
###################### Source Account ########################

variable "source_vpc_id" {
  description = "The VPC ID for the Transit Gateway VPC attachment"
  type        = string
}

variable "source_subnet_ids" {
  description = "List of subnet IDs for the Transit Gateway VPC attachment"
  type        = list(string)
}

variable "source_route_table_ids" {
  description = "Route table ID to add routes to"
  type        = list(any)
}

variable "destination_cidr_block" {
  description = "Destination CIDR block for the route"
  type        = string
}
#######################################################################

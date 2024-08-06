# modules/transit_gateway/variables.tf
variable "account_ids" {
  description = "List of account IDs to share the Transit Gateway with"
  type        = list(string)
}


# modules/ram_share_accepter/variables.tf
variable "resource_share_arn" {
  description = "The ARN of the RAM resource share"
  type        = string
}



# modules/transit_gateway_attachment/variables.tf
variable "transit_gateway_id" {
  description = "The ID of the Transit Gateway"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to attach to the Transit Gateway"
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of the subnets to use for the VPC attachment"
  type        = list(string)
}

variable "route_table_associations" {
  description = "List of CIDR blocks to associate with the route table"
  type        = list(string)
}

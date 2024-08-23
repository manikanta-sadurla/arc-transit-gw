output "transit_gateway_arn" {
  value = length(aws_ec2_transit_gateway.transit_gateway) > 0 ? aws_ec2_transit_gateway.transit_gateway[0].arn : null
}

output "transit_gateway_id" {
  value = length(aws_ec2_transit_gateway.transit_gateway) > 0 ? aws_ec2_transit_gateway.transit_gateway[0].id : null
}

region                 = "us-east-1"
transit_gateway_name   = "Log-Archive-Transit-GW"
transit_gateway_asn    = 64512
vpc_id                 = "vpc-04b82dc8a034d7004"
subnet_ids              = [
  "subnet-050501c4bb21ce041",
  "subnet-0e36d58a2c71f52d7"
]
route_table_id         = "rtb-0727aefad8008b632"
destination_cidr_block = "10.1.0.0/22"
target_account_id      = "654654163064"
assume_role_arn        = "arn:aws:iam::654654163064:role/arc-destination-role"

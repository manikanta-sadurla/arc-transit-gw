region            = "us-east-1"
target_account_id = ["654654163064"] # RAM To share Transit to other accounts
vpc_id            = "vpc-021a5ebd8765454be"
subnet_ids        = ["subnet-0967757bbf9e8b397", "subnet-0ba1d81aa9a056822"]
route_table_ids   = ["rtb-03694d12130a3ee16", "rtb-0a95cb0a679c62206"]
source_cidr_block = "10.60.0.0/16"
# assume_role_arn   = "arn:aws:iam::654654163064:role/arc-destination-role"

################### SOURCE ########################
transit_gateway_name   = "Log-Archive-Transit-GW"
source_vpc_id          = "vpc-0828676a85368a010"
source_subnet_ids      = ["subnet-0bd3777718064b8c1", "subnet-0ceedb9d964271d63"]
source_route_table_ids = ["rtb-0f47f5b2f4294ed68", "rtb-0f91ca3850d4802eb"]
destination_cidr_block = "10.10.0.0/16"


existing_transit_gateway_arn = "arn:aws:ec2:us-east-1:533267341577:transit-gateway/tgw-0ac3a013ce5be122c"
existing_transit_gateway_id  = "tgw-0ac3a013ce5be122c"

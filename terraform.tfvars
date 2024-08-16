region = "us-east-1"

vpc_id = "vpc-0f6665a372350c85b"
subnet_ids = [
  "subnet-0374e641f2245a83a",
  "subnet-061841b07283caaa9"
]
route_table_ids   = ["rtb-040a6ce2bdf06f7e4", "rtb-0bc113b0512304300"]
source_cidr_block = "10.60.0.0/16"
target_account_id = "654654163064"
assume_role_arn   = "arn:aws:iam::654654163064:role/arc-destination-role"

################### SOURCE ########################
transit_gateway_name   = "Log-Archive-Transit-GW"
transit_gateway_asn    = 64512
source_vpc_id          = "vpc-092b247497a1e2b72"
source_subnet_ids      = ["subnet-05f02e2413021ebac", "subnet-0a230035a4c287807"]
source_route_table_ids = ["rtb-0609322670ebabf9a", "rtb-091ac2477432323ea"]
destination_cidr_block = "10.10.0.0/16"

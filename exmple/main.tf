terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      version               = "~> 4.0"
      source                = "hashicorp/aws"
      configuration_aliases = [aws.target]
    }

    awsutils = {
      source  = "cloudposse/awsutils"
      version = "~> 0.15"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "awsutils" {
  region = var.region
}

provider "aws" {
  alias  = "target"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::654654163064:role/arc-destination-role"
  }
}

module "transit_gateway" {
  source = "../."

  region                       = "us-east-1"
  create_transit_gateway       = false
  existing_transit_gateway_arn = "arn:aws:ec2:us-east-1:533267341577:transit-gateway/tgw-0ac3a013ce5be122c"
  existing_transit_gateway_id  = "tgw-0ac3a013ce5be122c"
  target_account_id            = ["654654163064"]
  source_vpc_id                = "vpc-0828676a85368a010"
  source_subnet_ids            = ["subnet-0bd3777718064b8c1", "subnet-0ceedb9d964271d63"]
  source_route_table_ids       = ["rtb-0f47f5b2f4294ed68", "rtb-0f91ca3850d4802eb"]
  destination_cidr_block       = "10.10.0.0/16"
  providers = {
    aws        = aws
    aws.target = aws.target
  }

  vpc_id            = "vpc-021a5ebd8765454be"
  subnet_ids        = ["subnet-0967757bbf9e8b397", "subnet-0ba1d81aa9a056822"]
  route_table_ids   = ["rtb-03694d12130a3ee16", "rtb-0a95cb0a679c62206"]
  source_cidr_block = "10.60.0.0/16"

}



# provider "aws" {
#   alias  = "target2"
#   region = "us-east-1"
#   assume_role {
#     role_arn = "arn:aws:iam::992382551538:role/arc-destination-role-2"
#   }
# }

# module "transit_gateway_target2" {
#   source = "../."

#   region                       = "us-east-1"
#   create_transit_gateway       = false
#   existing_transit_gateway_arn = "arn:aws:ec2:us-east-1:533267341577:transit-gateway/tgw-0ac3a013ce5be122c"
#   existing_transit_gateway_id  = "tgw-0ac3a013ce5be122c"

#   source_vpc_id                = "vpc-0828676a85368a010"
#   source_subnet_ids            = ["subnet-0bd3777718064b8c1", "subnet-0ceedb9d964271d63"]
  
#   target_account_id      = ["992382551538"]
#   destination_cidr_block = "10.0.0.0/16"

#   providers = {
#     aws        = aws
#     aws.target = aws.target2
#   }

#   vpc_id            = "vpc-0d56ce6a38df0434e" # New target account VPC ID
#   subnet_ids        = ["subnet-033eebbeceed00181", "subnet-034a98a9e9d325bd6"]
#   route_table_ids   = ["rtb-0ca108fb6702dbb22", "rtb-0d50d045823996e9e"]
#   source_cidr_block = "10.60.0.0/16"
# }

# main.tf
provider "aws" {
  alias  = "main"
  region = "us-east-1"
}

provider "aws" {
  alias  = "destination"
  region = "us-east-1"
  assume_role {
    role_arn = local.environment_role["destination"]
  }
}

module "transit" {
  # source = "./modules/transit_gateway"
  source = "./"
  account_ids = ["111111111111", "222222222222"]  # Replace with actual account IDs
}

module "ram_acceptor" {
  source = "./modules/ram_share_accepter"
  providers = {
    aws = aws.destination
  }

  resource_share_arn = module.transit.resource_share_arn
}

module "transit_attachment" {
  source = "./modules/transit_gateway_attachment"
  providers = {
    aws = aws.destination
  }

  transit_gateway_id      = module.transit.transit_gateway_id
  vpc_id                  = "vpc-12345678"         # Replace with actual VPC ID
  subnet_ids              = ["subnet-12345678"]    # Replace with actual subnet IDs
  route_table_associations = ["10.0.0.0/16"]       # Replace with actual CIDR blocks
  depends_on = [module.ram_acceptor]
}



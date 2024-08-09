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
# #   assume_role {
# #     role_arn = local.environment_role[var.environment]
# #   }
# #   default_tags {
# #     tags = module.tags.tags
# #   }
# }

# provider "awsutils" {
#   region = var.region
# #   assume_role {
# #     role_arn = local.environment_role[var.environment]
# #   }
# }


terraform {
  required_version = ">= 0.12.26"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# data "aws_caller_identity" "current" {}
# locals {
#   account_id = data.aws_caller_identity.current.account_id
# }

data "aws_region" "current" {}

locals {
  region = data.aws_region.current.name
}

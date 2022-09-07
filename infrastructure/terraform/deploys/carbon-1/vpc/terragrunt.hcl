inputs = {
  aws   = local.defaults.aws
  label = local.defaults.label

  cidr_range           = "10.0.0.0/16"
  cidr_subnets_private = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  cidr_subnets_public  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

locals {
  defaults = read_terragrunt_config(
    find_in_parent_folders("config.hcl")
  ).inputs
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../..//modules/vpc"
}

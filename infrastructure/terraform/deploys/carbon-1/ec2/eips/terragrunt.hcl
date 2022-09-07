inputs = {
  aws   = local.defaults.aws
  label = local.defaults.label

  availability_zones = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
  ]
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
  source = "../../../..//modules/ec2/eips"
}

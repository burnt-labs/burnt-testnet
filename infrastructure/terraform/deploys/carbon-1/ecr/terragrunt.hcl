inputs = {
  aws   = local.defaults.aws
  label = local.defaults.label

  repositories = [
    "base-image",
    "node",
  ]

  storage_key_arn = dependency.this_kms.outputs.storage_key.arn
}

dependency "this_kms" {
  config_path = "..//kms"
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
  source = "../../..//modules/ecr"
}

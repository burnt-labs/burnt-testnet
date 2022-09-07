inputs = {
  aws   = local.defaults.aws
  label = local.defaults.label

  secrets_key_arn = dependency.this_kms.outputs.secrets_key.arn

  secrets = [
    "carbon-1/node/node-key",
    "carbon-1/node/priv-validator-key",
  ]
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
  source = "../../..//modules/secrets"
}

inputs = {
  aws   = local.defaults.aws
  label = local.defaults.label

  cluster_version = "1.23"
  addon_versions = {
    coredns    = "v1.8.7-eksbuild.2"
    kube_proxy = "v1.23.7-eksbuild.1"
    vpc_cni    = "v1.11.3-eksbuild.1"
  }

  secrets_key_arn = dependency.this_kms.outputs.secrets_key.arn
  storage_key_arn = dependency.this_kms.outputs.storage_key.arn

  subnet_ids = dependency.this_vpc.outputs.vpc.subnet_ids
  vpc_id     = dependency.this_vpc.outputs.vpc.vpc_id
}

dependency "this_kms" {
  config_path = "../..//kms"
}

dependency "this_vpc" {
  config_path = "../..//vpc"
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
  source = "../../../..//modules/eks/cluster"
}

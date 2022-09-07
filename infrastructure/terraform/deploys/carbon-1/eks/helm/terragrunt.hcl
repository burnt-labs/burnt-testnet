inputs = {
  aws   = local.defaults.aws
  label = local.defaults.label

  cluster_ca_cert  = dependency.this_eks.outputs.eks.ca_cert
  cluster_endpoint = dependency.this_eks.outputs.eks.endpoint
  cluster_id       = dependency.this_eks.outputs.eks.id
  oidc_arn         = dependency.this_eks.outputs.eks.oidc_arn

  chart_versions = {
    cluster_autoscaler = "9.20.1"
    ebs_csi            = "2.10.1"
    external_secrets   = "0.5.9"
    lb_controller      = "1.4.2"
  }

  storage_key_arn = dependency.this_kms.outputs.storage_key.arn
}

dependency "this_eks" {
  config_path = "..//cluster"
}

dependency "this_kms" {
  config_path = "../..//kms"
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
  source = "../../../..//modules/eks/helm"
}

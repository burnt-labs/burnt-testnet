output "eks" {
  value = {
    addons = { for k, v in module.eks.cluster_addons :
      k => v.addon_version
    }
    ca_cert  = module.eks.cluster_certificate_authority_data
    endpoint = module.eks.cluster_endpoint
    id       = module.eks.cluster_id
    oidc_arn = module.eks.oidc_provider_arn
    version  = module.eks.cluster_version
  }
}

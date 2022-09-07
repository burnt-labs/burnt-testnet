#
# IAM // Role for Service Accounts
# See: https://github.com/terraform-aws-modules/terraform-aws-iam/blob/master/examples/iam-role-for-service-accounts-eks/main.tf
#
module "burnt_node_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                             = "${var.label.namespace}-${var.label.environment}-node"
  attach_external_secrets_policy        = true
  external_secrets_secrets_manager_arns = ["arn:aws:secretsmanager:${var.aws.region}:${var.aws.account_id}:secret:/testnet/carbon-1/node/*"]

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_arn
      namespace_service_accounts = ["carbon-1:node"]
    }
  }

  tags = module.label.tags
}

#
# Helm // external-secrets
# See: https://artifacthub.io/packages/helm/external-secrets-operator/external-secrets
#
resource "helm_release" "external_secrets" {
  name      = "external-secrets"
  namespace = "kube-system"

  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = var.chart_versions.external_secrets

  set {
    name  = "replicaCount"
    value = "1"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-secrets"
  }
}

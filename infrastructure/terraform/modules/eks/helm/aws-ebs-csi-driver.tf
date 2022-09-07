#
# IAM // Role for Service Account - EBS CSI
# See: https://github.com/terraform-aws-modules/terraform-aws-iam/blob/master/examples/iam-role-for-service-accounts-eks/main.tf
#
module "ebs_csi_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${var.label.namespace}-${var.label.environment}-ebs-csi"
  attach_ebs_csi_policy = true
  ebs_csi_kms_cmk_ids   = [var.storage_key_arn]

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = module.label.tags
}

#
# Helm // aws-ebs-csi-driver
# See: https://github.com/kubernetes-sigs/aws-ebs-csi-driver
#
resource "helm_release" "ebs_csi" {
  name      = "aws-ebs-csi-driver"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  version    = var.chart_versions.ebs_csi

  set {
    name  = "controller.serviceAccount.create"
    value = true
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "ebs-csi-controller-sa"
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.ebs_csi_irsa.iam_role_arn
  }

  set {
    name  = "node.serviceAccount.create"
    value = false
  }

  set {
    name  = "node.serviceAccount.name"
    value = "ebs-csi-controller-sa"
  }

  set {
    name  = "node.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.ebs_csi_irsa.iam_role_arn
  }

  set {
    name  = "node.tolerateAllTaints"
    value = true
  }
}

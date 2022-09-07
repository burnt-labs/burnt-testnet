#
# Label
# see: https://github.com/cloudposse/terraform-null-label
#
module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = var.label.namespace
  stage       = var.label.stage
  name        = "helm"
  environment = var.label.environment
  tags        = var.label.tags

  label_order = ["namespace", "environment", "name"]
}

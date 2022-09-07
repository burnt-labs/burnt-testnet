#
# Label
# see: https://github.com/cloudposse/terraform-null-label
#
module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = var.label.namespace
  stage       = var.label.stage
  name        = "secrets"
  environment = var.label.environment
  tags        = var.label.tags

  label_order = ["namespace", "environment", "name"]
}

#
# Secrets Manager // Secret
#
resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name                    = format("/%s/%s", module.label.stage, each.value)
  description             = module.label.id
  kms_key_id              = var.secrets_key_arn
  recovery_window_in_days = 0

  tags = module.label.tags
}

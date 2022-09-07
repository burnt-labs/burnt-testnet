#
# Label
# see: https://github.com/cloudposse/terraform-null-label
#
module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = var.label.namespace
  stage       = var.label.stage
  name        = "kms"
  environment = var.label.environment
  tags        = var.label.tags

  label_order = ["namespace", "environment", "name"]
}

#
# KMS // Secrets key
#
module "secrets_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.1.0"

  deletion_window_in_days = 7
  description             = "${module.label.id}-secrets"
  enable_key_rotation     = true
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = false

  # Policy
  policy = data.aws_iam_policy_document.secrets_policy.json

  # Aliases
  aliases                 = ["${module.label.id}-secrets"]
  aliases_use_name_prefix = false

  tags = module.label.tags
}

#
# KMS // Storage key
#
module "storage_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.1.0"

  deletion_window_in_days = 7
  description             = "${module.label.id}-storage"
  enable_key_rotation     = true
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = false

  # Policy
  policy = data.aws_iam_policy_document.storage_policy.json

  # Aliases
  aliases                 = ["${module.label.id}-storage"]
  aliases_use_name_prefix = false

  tags = module.label.tags
}

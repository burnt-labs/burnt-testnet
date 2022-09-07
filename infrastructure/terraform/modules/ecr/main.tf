#
# Label
# see: https://github.com/cloudposse/terraform-null-label
#
module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = var.label.namespace
  stage       = var.label.stage
  name        = "ecr"
  environment = var.label.environment
  tags        = var.label.tags

  label_order = ["namespace", "environment", "name"]
}

#
# ECR
# See: https://github.com/terraform-aws-modules/terraform-aws-ecr
#
module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "1.4.0"

  for_each = var.repositories

  repository_name            = each.value
  repository_encryption_type = "KMS"
  repository_kms_key         = var.storage_key_arn
  create_lifecycle_policy    = false
  repository_force_delete    = true

  tags = module.label.tags
}

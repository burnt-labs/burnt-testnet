#
# Label
# see: https://github.com/cloudposse/terraform-null-label
#
module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = var.label.namespace
  stage       = var.label.stage
  name        = "eips"
  environment = var.label.environment
  tags        = var.label.tags

  label_order = ["namespace", "environment", "name"]
}

#
# EC2 // Elastic IPs
#
resource "aws_eip" "node" {
  for_each = var.availability_zones

  tags = merge(module.label.tags, {
    Name = format("%s-%s", module.label.id, substr(each.value, -1, 1))
  })

  vpc = true
}

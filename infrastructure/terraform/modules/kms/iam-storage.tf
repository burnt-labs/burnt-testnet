#
# IAM // Storage key policy
#
data "aws_iam_policy_document" "storage_policy" {
  statement {
    sid = "ManageWithKey"
    principals {
      identifiers = [
        "arn:aws:iam::${var.aws.account_id}:root"
      ]
      type = "AWS"
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid = "EncryptDecryptWithKey"
    principals {
      identifiers = var.storage_principals.encrypt.services
      type        = "Service"
    }
    principals {
      identifiers = concat(["arn:aws:iam::${var.aws.account_id}:root"], var.storage_principals.encrypt.aws)
      type        = "AWS"
    }
    effect = "Allow"
    actions = [
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }

  statement {
    sid = "GrantWithKey"
    principals {
      identifiers = concat(["arn:aws:iam::${var.aws.account_id}:root"], var.storage_principals.grant.aws)
      type        = "AWS"
    }
    effect    = "Allow"
    actions   = ["kms:CreateGrant"]
    resources = ["*"]
  }
}

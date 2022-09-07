output "this" {
  value = { for k, v in aws_secretsmanager_secret.this :
    k => {
      arn        = v.arn
      name       = v.name
      kms_key_id = v.kms_key_id
    }
  }
}

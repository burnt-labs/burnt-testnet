output "secrets_key" {
  value = {
    arn = module.secrets_key.key_arn
    id  = module.secrets_key.key_id
  }
}

output "storage_key" {
  value = {
    arn = module.storage_key.key_arn
    id  = module.storage_key.key_id
  }
}

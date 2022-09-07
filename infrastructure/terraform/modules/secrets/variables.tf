#
# Common vars
#
variable "aws" {
  description = "AWS provider variables"
  type = object({
    account_id = string
    region     = string
    role_arn   = string
  })
}

variable "label" {
  description = "Module labels"
  type = object({
    namespace   = string
    stage       = string
    environment = string
    tags        = map(string)
  })
}

#
# Specific vars
#
variable "secrets_key_arn" {
  description = "The ARN of the KMS key to encrypt values with"
  type        = string
}

variable "secrets" {
  description = "Set of Secrets to create"
  type        = set(string)
}

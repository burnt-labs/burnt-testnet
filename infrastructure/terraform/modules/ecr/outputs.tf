output "ecr" {
  value = { for k, v in module.ecr :
    k => {
      arn = v.repository_arn
      url = v.repository_url
    }
  }
}

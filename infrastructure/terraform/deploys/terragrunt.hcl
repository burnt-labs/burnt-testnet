remote_state {
  backend = "s3"

  config = {
    bucket         = "my-terraform-bucket"
    dynamodb_table = "my-terraform-bucket"
    encrypt        = true
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
  }
}

terraform {
  extra_arguments "conditional_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "refresh"
    ]

    optional_var_files = [
      "${get_parent_terragrunt_dir()}/terraform.tfvars",
      "${get_terragrunt_dir()}/terraform.tfvars",
    ]

    required_var_files = []
  }

  extra_arguments "retry_lock" {
    commands = get_terraform_commands_that_need_locking()

    arguments = [
      "-lock-timeout=5m"
    ]
  }

  before_hook "module_update" {
    commands = ["plan", "apply"]
    execute  = ["terraform", "get"]
  }
}

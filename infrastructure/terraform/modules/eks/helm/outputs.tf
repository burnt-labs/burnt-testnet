output "irsa_arns" {
  value = {
    cluster_autoscaler = module.cluster_autoscaler_irsa.iam_role_arn
    external_secrets = {
      burnt_node = module.burnt_node_irsa.iam_role_arn
    }
    lb_controller = module.lb_controller_irsa.iam_role_arn
  }
}

output "helm" {
  value = {
    cluster_autoscaler = {
      name        = helm_release.cluster_autoscaler.metadata[0].name
      version     = helm_release.cluster_autoscaler.metadata[0].version
      app_version = helm_release.cluster_autoscaler.metadata[0].app_version
    }
    ebs_csi = {
      name        = helm_release.ebs_csi.metadata[0].name
      version     = helm_release.ebs_csi.metadata[0].version
      app_version = helm_release.ebs_csi.metadata[0].app_version
    }
    external_secrets = {
      name        = helm_release.external_secrets.metadata[0].name
      version     = helm_release.external_secrets.metadata[0].version
      app_version = helm_release.external_secrets.metadata[0].app_version
    }
    lb_controller = {
      name        = helm_release.lb_controller.metadata[0].name
      version     = helm_release.lb_controller.metadata[0].version
      app_version = helm_release.lb_controller.metadata[0].app_version
    }
  }
}
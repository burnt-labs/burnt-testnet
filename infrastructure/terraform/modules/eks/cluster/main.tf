#
# Label
# see: https://github.com/cloudposse/terraform-null-label
#
module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = var.label.namespace
  stage       = var.label.stage
  name        = "eks"
  environment = var.label.environment
  tags        = var.label.tags

  label_order = ["namespace", "environment", "name"]
}

locals {
  eks_cluster_name = "${module.label.namespace}-${module.label.environment}"
}

#
# EKS // Cluster
# see: https://github.com/terraform-aws-modules/terraform-aws-eks
#
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.29.0"

  cluster_name                    = local.eks_cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      addon_version     = var.addon_versions.coredns
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      addon_version     = var.addon_versions.kube_proxy
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      addon_version     = var.addon_versions.vpc_cni
      resolve_conflicts = "OVERWRITE"
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = var.secrets_key_arn
    resources        = ["secrets"]
  }]

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids.private

  create_aws_auth_configmap = false
  manage_aws_auth_configmap = true

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_cluster = {
      description                   = "Cluster API to node groups 1025-65535"
      protocol                      = "tcp"
      from_port                     = 1025
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    },
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_group_defaults = {
    ami_type                   = "AL2_x86_64"
    instance_types             = ["m6i.large"]
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    default = {
      name            = "${module.label.id}-default"
      use_name_prefix = false

      subnet_ids = var.subnet_ids.private

      min_size     = 1
      max_size     = 5
      desired_size = 1

      ami_id                     = data.aws_ami.eks_default.image_id
      enable_bootstrap_user_data = true
      bootstrap_extra_args       = "--container-runtime containerd --kubelet-extra-args '--max-pods=110'"

      pre_bootstrap_user_data = <<-EOT
      export CONTAINER_RUNTIME="containerd"
      export USE_MAX_PODS=false
      EOT

      description = module.label.id

      ebs_optimized           = true
      vpc_security_group_ids  = []
      disable_api_termination = false
      enable_monitoring       = true

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 100
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            kms_key_id            = var.storage_key_arn
            delete_on_termination = true
          }
        }
      }

      create_iam_role          = true
      iam_role_name            = "${module.label.id}-default"
      iam_role_use_name_prefix = false
      iam_role_description     = "${module.label.id}-default"
      iam_role_tags            = module.label.tags
      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
      ]

      create_security_group = false

      tags = merge({
        "k8s.io/cluster-autoscaler/enabled"                   = true
        "k8s.io/cluster-autoscaler/${local.eks_cluster_name}" = "owned"
      }, module.label.tags)
    }
  }

  tags = module.label.tags
}

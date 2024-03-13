locals {
  cluster_name                                       = "k8s-dev.schlafdata.cloud"
  default-aws-lb-controller_role_arn                 = aws_iam_role.aws-lb-controller-default-sa-k8s-dev-schlafdata-cloud.arn
  default-aws-lb-controller_role_name                = aws_iam_role.aws-lb-controller-default-sa-k8s-dev-schlafdata-cloud.name
  default-ecr_role_arn                               = aws_iam_role.ecr-default-sa-k8s-dev-schlafdata-cloud.arn
  default-ecr_role_name                              = aws_iam_role.ecr-default-sa-k8s-dev-schlafdata-cloud.name
  default-efs-access-point-policy_role_arn           = aws_iam_role.efs-access-point-policy-default-sa-k8s-dev-schlafdata-cloud.arn
  default-efs-access-point-policy_role_name          = aws_iam_role.efs-access-point-policy-default-sa-k8s-dev-schlafdata-cloud.name
  default-efs-csi-controller-sa_role_arn             = aws_iam_role.efs-csi-controller-sa-default-sa-k8s-dev-schlafdata-cloud.arn
  default-efs-csi-controller-sa_role_name            = aws_iam_role.efs-csi-controller-sa-default-sa-k8s-dev-schlafdata-cloud.name
  default-external-dns_role_arn                      = aws_iam_role.external-dns-default-sa-k8s-dev-schlafdata-cloud.arn
  default-external-dns_role_name                     = aws_iam_role.external-dns-default-sa-k8s-dev-schlafdata-cloud.name
  default-kops_role_arn                              = aws_iam_role.kops-default-sa-k8s-dev-schlafdata-cloud.arn
  default-kops_role_name                             = aws_iam_role.kops-default-sa-k8s-dev-schlafdata-cloud.name
  iam_openid_connect_provider_arn                    = aws_iam_openid_connect_provider.k8s-dev-schlafdata-cloud.arn
  iam_openid_connect_provider_issuer                 = "iam-http-dir-dev-schlafdata-cloud.s3.us-west-2.amazonaws.com"
  kube-system-aws-cloud-controller-manager_role_arn  = aws_iam_role.aws-cloud-controller-manager-kube-system-sa-k8s-dev-schla-c9672l.arn
  kube-system-aws-cloud-controller-manager_role_name = aws_iam_role.aws-cloud-controller-manager-kube-system-sa-k8s-dev-schla-c9672l.name
  kube-system-aws-node-termination-handler_role_arn  = aws_iam_role.aws-node-termination-handler-kube-system-sa-k8s-dev-schla-q8li9f.arn
  kube-system-aws-node-termination-handler_role_name = aws_iam_role.aws-node-termination-handler-kube-system-sa-k8s-dev-schla-q8li9f.name
  kube-system-cert-manager_role_arn                  = aws_iam_role.cert-manager-kube-system-sa-k8s-dev-schlafdata-cloud.arn
  kube-system-cert-manager_role_name                 = aws_iam_role.cert-manager-kube-system-sa-k8s-dev-schlafdata-cloud.name
  kube-system-cluster-autoscaler_role_arn            = aws_iam_role.cluster-autoscaler-kube-system-sa-k8s-dev-schlafdata-cloud.arn
  kube-system-cluster-autoscaler_role_name           = aws_iam_role.cluster-autoscaler-kube-system-sa-k8s-dev-schlafdata-cloud.name
  kube-system-dns-controller_role_arn                = aws_iam_role.dns-controller-kube-system-sa-k8s-dev-schlafdata-cloud.arn
  kube-system-dns-controller_role_name               = aws_iam_role.dns-controller-kube-system-sa-k8s-dev-schlafdata-cloud.name
  kube-system-ebs-csi-controller-sa_role_arn         = aws_iam_role.ebs-csi-controller-sa-kube-system-sa-k8s-dev-schlafdata-cloud.arn
  kube-system-ebs-csi-controller-sa_role_name        = aws_iam_role.ebs-csi-controller-sa-kube-system-sa-k8s-dev-schlafdata-cloud.name
  master_autoscaling_group_ids                       = [aws_autoscaling_group.master-us-west-2a-masters-k8s-dev-schlafdata-cloud.id]
  master_security_group_ids                          = [aws_security_group.masters-k8s-dev-schlafdata-cloud.id]
  masters_role_arn                                   = aws_iam_role.masters-k8s-dev-schlafdata-cloud.arn
  masters_role_name                                  = aws_iam_role.masters-k8s-dev-schlafdata-cloud.name
  node_autoscaling_group_ids                         = [aws_autoscaling_group.gpu-nodes-g4dn-12xl-k8s-dev-schlafdata-cloud.id, aws_autoscaling_group.gpu-nodes-g4dn-2xl-k8s-dev-schlafdata-cloud.id, aws_autoscaling_group.gpu-nodes-g4dn-4xl-k8s-dev-schlafdata-cloud.id, aws_autoscaling_group.gpu-nodes-g4dn-xl-k8s-dev-schlafdata-cloud.id, aws_autoscaling_group.gpu-nodes-g5-12xl-k8s-dev-schlafdata-cloud.id, aws_autoscaling_group.gpu-nodes-g5-4xl-k8s-dev-schlafdata-cloud.id, aws_autoscaling_group.gpu-nodes-g5-xl-k8s-dev-schlafdata-cloud.id, aws_autoscaling_group.nodes-us-west-2a-k8s-dev-schlafdata-cloud.id]
  node_security_group_ids                            = [aws_security_group.nodes-k8s-dev-schlafdata-cloud.id]
  node_subnet_ids                                    = ["subnet-0d40e2efbf64ff3e5"]
  nodes_role_arn                                     = aws_iam_role.nodes-k8s-dev-schlafdata-cloud.arn
  nodes_role_name                                    = aws_iam_role.nodes-k8s-dev-schlafdata-cloud.name
  region                                             = "us-west-2"
  subnet_ids                                         = ["subnet-05268c0edf1653894", "subnet-0d40e2efbf64ff3e5"]
  subnet_us-west-2a_id                               = "subnet-0d40e2efbf64ff3e5"
  subnet_utility-us-west-2a_id                       = "subnet-05268c0edf1653894"
  vpc_cidr_block                                     = data.aws_vpc.k8s-dev-schlafdata-cloud.cidr_block
  vpc_id                                             = "vpc-0b5087f6bdafd0497"
  vpc_ipv6_cidr_block                                = data.aws_vpc.k8s-dev-schlafdata-cloud.ipv6_cidr_block
  vpc_ipv6_cidr_length                               = local.vpc_ipv6_cidr_block == "" ? null : tonumber(regex(".*/(\\d+)", local.vpc_ipv6_cidr_block)[0])
}

output "cluster_name" {
  value = "k8s-dev.schlafdata.cloud"
}

output "default-aws-lb-controller_role_arn" {
  value = aws_iam_role.aws-lb-controller-default-sa-k8s-dev-schlafdata-cloud.arn
}

output "default-aws-lb-controller_role_name" {
  value = aws_iam_role.aws-lb-controller-default-sa-k8s-dev-schlafdata-cloud.name
}

output "default-ecr_role_arn" {
  value = aws_iam_role.ecr-default-sa-k8s-dev-schlafdata-cloud.arn
}

output "default-ecr_role_name" {
  value = aws_iam_role.ecr-default-sa-k8s-dev-schlafdata-cloud.name
}

output "default-efs-access-point-policy_role_arn" {
  value = aws_iam_role.efs-access-point-policy-default-sa-k8s-dev-schlafdata-cloud.arn
}

output "default-efs-access-point-policy_role_name" {
  value = aws_iam_role.efs-access-point-policy-default-sa-k8s-dev-schlafdata-cloud.name
}

output "default-efs-csi-controller-sa_role_arn" {
  value = aws_iam_role.efs-csi-controller-sa-default-sa-k8s-dev-schlafdata-cloud.arn
}

output "default-efs-csi-controller-sa_role_name" {
  value = aws_iam_role.efs-csi-controller-sa-default-sa-k8s-dev-schlafdata-cloud.name
}

output "default-external-dns_role_arn" {
  value = aws_iam_role.external-dns-default-sa-k8s-dev-schlafdata-cloud.arn
}

output "default-external-dns_role_name" {
  value = aws_iam_role.external-dns-default-sa-k8s-dev-schlafdata-cloud.name
}

output "default-kops_role_arn" {
  value = aws_iam_role.kops-default-sa-k8s-dev-schlafdata-cloud.arn
}

output "default-kops_role_name" {
  value = aws_iam_role.kops-default-sa-k8s-dev-schlafdata-cloud.name
}

output "iam_openid_connect_provider_arn" {
  value = aws_iam_openid_connect_provider.k8s-dev-schlafdata-cloud.arn
}

output "iam_openid_connect_provider_issuer" {
  value = "iam-http-dir-dev-schlafdata-cloud.s3.us-west-2.amazonaws.com"
}

output "kube-system-aws-cloud-controller-manager_role_arn" {
  value = aws_iam_role.aws-cloud-controller-manager-kube-system-sa-k8s-dev-schla-c9672l.arn
}

output "kube-system-aws-cloud-controller-manager_role_name" {
  value = aws_iam_role.aws-cloud-controller-manager-kube-system-sa-k8s-dev-schla-c9672l.name
}

output "kube-system-aws-node-termination-handler_role_arn" {
  value = aws_iam_role.aws-node-termination-handler-kube-system-sa-k8s-dev-schla-q8li9f.arn
}

output "kube-system-aws-node-termination-handler_role_name" {
  value = aws_iam_role.aws-node-termination-handler-kube-system-sa-k8s-dev-schla-q8li9f.name
}

output "kube-system-cert-manager_role_arn" {
  value = aws_iam_role.cert-manager-kube-system-sa-k8s-dev-schlafdata-cloud.arn
}

output "kube-system-cert-manager_role_name" {
  value = aws_iam_role.cert-manager-kube-system-sa-k8s-dev-schlafdata-cloud.name
}

output "kube-system-cluster-autoscaler_role_arn" {
  value = aws_iam_role.cluster-autoscaler-kube-system-sa-k8s-dev-schlafdata-cloud.arn
}

output "kube-system-cluster-autoscaler_role_name" {
  value = aws_iam_role.cluster-autoscaler-kube-system-sa-k8s-dev-schlafdata-cloud.name
}

output "kube-system-dns-controller_role_arn" {
  value = aws_iam_role.dns-controller-kube-system-sa-k8s-dev-schlafdata-cloud.arn
}

output "kube-system-dns-controller_role_name" {
  value = aws_iam_role.dns-controller-kube-system-sa-k8s-dev-schlafdata-cloud.name
}

output "kube-system-ebs-csi-controller-sa_role_arn" {
  value = aws_iam_role.ebs-csi-controller-sa-kube-system-sa-k8s-dev-schlafdata-cloud.arn
}

output "kube-system-ebs-csi-controller-sa_role_name" {
  value = aws_iam_role.ebs-csi-controller-sa-kube-system-sa-k8s-dev-schlafdata-cloud.name
}

output "master_autoscaling_group_ids" {
  value = [aws_autoscaling_group.master-us-west-2a-masters-k8s-dev-schlafdata-cloud.id]
}

output "master_security_group_ids" {
  value = [aws_security_group.masters-k8s-dev-schlafdata-cloud.id]
}

output "masters_role_arn" {
  value = aws_iam_role.masters-k8s-dev-schlafdata-cloud.arn
}

output "masters_role_name" {
  value = aws_iam_role.masters-k8s-dev-schlafdata-cloud.name
}

output "node_autoscaling_group_ids" {
  value = [aws_autoscaling_group.gpu-nodes-g4dn-12xl-k8s-dev-schlafdata-cloud.id, aws_autoscaling_group.gpu-nodes-g4dn-2xl-k8s-dev-schlafdata-cloud.id, aws_autoscaling_group.gpu-nodes-g4dn-4xl-k8s-dev-schlafdata-cloud.id, aws_autoscaling_group.gpu-nodes-g4dn-xl-k8s-dev-schlafdata-cloud.id, aws_autoscaling_group.gpu-nodes-g5-12xl-k8s-dev-schlafdata-cloud.id, aws_autoscaling_group.gpu-nodes-g5-4xl-k8s-dev-schlafdata-cloud.id, aws_autoscaling_group.gpu-nodes-g5-xl-k8s-dev-schlafdata-cloud.id, aws_autoscaling_group.nodes-us-west-2a-k8s-dev-schlafdata-cloud.id]
}

output "node_security_group_ids" {
  value = [aws_security_group.nodes-k8s-dev-schlafdata-cloud.id]
}

output "node_subnet_ids" {
  value = ["subnet-0d40e2efbf64ff3e5"]
}

output "nodes_role_arn" {
  value = aws_iam_role.nodes-k8s-dev-schlafdata-cloud.arn
}

output "nodes_role_name" {
  value = aws_iam_role.nodes-k8s-dev-schlafdata-cloud.name
}

output "region" {
  value = "us-west-2"
}

output "subnet_ids" {
  value = ["subnet-05268c0edf1653894", "subnet-0d40e2efbf64ff3e5"]
}

output "subnet_us-west-2a_id" {
  value = "subnet-0d40e2efbf64ff3e5"
}

output "subnet_utility-us-west-2a_id" {
  value = "subnet-05268c0edf1653894"
}

output "vpc_cidr_block" {
  value = data.aws_vpc.k8s-dev-schlafdata-cloud.cidr_block
}

output "vpc_id" {
  value = "vpc-0b5087f6bdafd0497"
}

output "vpc_ipv6_cidr_block" {
  value = data.aws_vpc.k8s-dev-schlafdata-cloud.ipv6_cidr_block
}

output "vpc_ipv6_cidr_length" {
  value = local.vpc_ipv6_cidr_block == "" ? null : tonumber(regex(".*/(\\d+)", local.vpc_ipv6_cidr_block)[0])
}

provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "files"
  region = "us-west-2"
}

resource "aws_autoscaling_group" "gpu-nodes-g4dn-12xl-k8s-dev-schlafdata-cloud" {
  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  launch_template {
    id      = aws_launch_template.gpu-nodes-g4dn-12xl-k8s-dev-schlafdata-cloud.id
    version = aws_launch_template.gpu-nodes-g4dn-12xl-k8s-dev-schlafdata-cloud.latest_version
  }
  max_instance_lifetime = 0
  max_size              = 1
  metrics_granularity   = "1Minute"
  min_size              = 0
  name                  = "gpu-nodes-g4dn-12xl.k8s-dev.schlafdata.cloud"
  protect_from_scale_in = false
  tag {
    key                 = "KubernetesCluster"
    propagate_at_launch = true
    value               = "k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "gpu-nodes-g4dn-12xl.k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "aws-node-termination-handler/managed"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "gpus"
    propagate_at_launch = true
    value               = "4"
  }
  tag {
    key                 = "instance_type"
    propagate_at_launch = true
    value               = "g4dn-12xl"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/instance-group"
    propagate_at_launch = true
    value               = "gpu-nodes-g4dn-12xl"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/role/node"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "gpu-nodes-g4dn-12xl"
  }
  tag {
    key                 = "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"
    propagate_at_launch = true
    value               = "owned"
  }
  tag {
    key                 = "node_type"
    propagate_at_launch = true
    value               = "gpu"
  }
  vpc_zone_identifier = ["subnet-0d40e2efbf64ff3e5"]
}

resource "aws_autoscaling_group" "gpu-nodes-g4dn-2xl-k8s-dev-schlafdata-cloud" {
  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  launch_template {
    id      = aws_launch_template.gpu-nodes-g4dn-2xl-k8s-dev-schlafdata-cloud.id
    version = aws_launch_template.gpu-nodes-g4dn-2xl-k8s-dev-schlafdata-cloud.latest_version
  }
  max_instance_lifetime = 0
  max_size              = 1
  metrics_granularity   = "1Minute"
  min_size              = 0
  name                  = "gpu-nodes-g4dn-2xl.k8s-dev.schlafdata.cloud"
  protect_from_scale_in = false
  tag {
    key                 = "KubernetesCluster"
    propagate_at_launch = true
    value               = "k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "gpu-nodes-g4dn-2xl.k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "aws-node-termination-handler/managed"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "gpus"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "instance_type"
    propagate_at_launch = true
    value               = "g4dn-2xl"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/instance-group"
    propagate_at_launch = true
    value               = "gpu-nodes-g4dn-2xl"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/role/node"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "gpu-nodes-g4dn-2xl"
  }
  tag {
    key                 = "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"
    propagate_at_launch = true
    value               = "owned"
  }
  tag {
    key                 = "node_type"
    propagate_at_launch = true
    value               = "gpu"
  }
  vpc_zone_identifier = ["subnet-0d40e2efbf64ff3e5"]
}

resource "aws_autoscaling_group" "gpu-nodes-g4dn-4xl-k8s-dev-schlafdata-cloud" {
  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  launch_template {
    id      = aws_launch_template.gpu-nodes-g4dn-4xl-k8s-dev-schlafdata-cloud.id
    version = aws_launch_template.gpu-nodes-g4dn-4xl-k8s-dev-schlafdata-cloud.latest_version
  }
  max_instance_lifetime = 0
  max_size              = 1
  metrics_granularity   = "1Minute"
  min_size              = 0
  name                  = "gpu-nodes-g4dn-4xl.k8s-dev.schlafdata.cloud"
  protect_from_scale_in = false
  tag {
    key                 = "KubernetesCluster"
    propagate_at_launch = true
    value               = "k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "gpu-nodes-g4dn-4xl.k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "aws-node-termination-handler/managed"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "gpus"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "instance_type"
    propagate_at_launch = true
    value               = "g4dn-4xl"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/instance-group"
    propagate_at_launch = true
    value               = "gpu-nodes-g4dn-4xl"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/role/node"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "gpu-nodes-g4dn-4xl"
  }
  tag {
    key                 = "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"
    propagate_at_launch = true
    value               = "owned"
  }
  tag {
    key                 = "node_type"
    propagate_at_launch = true
    value               = "gpu"
  }
  vpc_zone_identifier = ["subnet-0d40e2efbf64ff3e5"]
}

resource "aws_autoscaling_group" "gpu-nodes-g4dn-xl-k8s-dev-schlafdata-cloud" {
  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  launch_template {
    id      = aws_launch_template.gpu-nodes-g4dn-xl-k8s-dev-schlafdata-cloud.id
    version = aws_launch_template.gpu-nodes-g4dn-xl-k8s-dev-schlafdata-cloud.latest_version
  }
  max_instance_lifetime = 0
  max_size              = 1
  metrics_granularity   = "1Minute"
  min_size              = 0
  name                  = "gpu-nodes-g4dn-xl.k8s-dev.schlafdata.cloud"
  protect_from_scale_in = false
  tag {
    key                 = "KubernetesCluster"
    propagate_at_launch = true
    value               = "k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "gpu-nodes-g4dn-xl.k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "aws-node-termination-handler/managed"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "gpus"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "instance_type"
    propagate_at_launch = true
    value               = "g4dn-xl"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/instance-group"
    propagate_at_launch = true
    value               = "gpu-nodes-g4dn-xl"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/role/node"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "gpu-nodes-g4dn-xl"
  }
  tag {
    key                 = "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"
    propagate_at_launch = true
    value               = "owned"
  }
  tag {
    key                 = "node_type"
    propagate_at_launch = true
    value               = "gpu"
  }
  vpc_zone_identifier = ["subnet-0d40e2efbf64ff3e5"]
}

resource "aws_autoscaling_group" "gpu-nodes-g5-12xl-k8s-dev-schlafdata-cloud" {
  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  launch_template {
    id      = aws_launch_template.gpu-nodes-g5-12xl-k8s-dev-schlafdata-cloud.id
    version = aws_launch_template.gpu-nodes-g5-12xl-k8s-dev-schlafdata-cloud.latest_version
  }
  max_instance_lifetime = 0
  max_size              = 1
  metrics_granularity   = "1Minute"
  min_size              = 0
  name                  = "gpu-nodes-g5-12xl.k8s-dev.schlafdata.cloud"
  protect_from_scale_in = false
  tag {
    key                 = "KubernetesCluster"
    propagate_at_launch = true
    value               = "k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "gpu-nodes-g5-12xl.k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "aws-node-termination-handler/managed"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "gpus"
    propagate_at_launch = true
    value               = "4"
  }
  tag {
    key                 = "instance_type"
    propagate_at_launch = true
    value               = "g5-12xl"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/instance-group"
    propagate_at_launch = true
    value               = "gpu-nodes-g5-12xl"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/role/node"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "gpu-nodes-g5-12xl"
  }
  tag {
    key                 = "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"
    propagate_at_launch = true
    value               = "owned"
  }
  tag {
    key                 = "node_type"
    propagate_at_launch = true
    value               = "gpu"
  }
  vpc_zone_identifier = ["subnet-0d40e2efbf64ff3e5"]
}

resource "aws_autoscaling_group" "gpu-nodes-g5-4xl-k8s-dev-schlafdata-cloud" {
  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  launch_template {
    id      = aws_launch_template.gpu-nodes-g5-4xl-k8s-dev-schlafdata-cloud.id
    version = aws_launch_template.gpu-nodes-g5-4xl-k8s-dev-schlafdata-cloud.latest_version
  }
  max_instance_lifetime = 0
  max_size              = 1
  metrics_granularity   = "1Minute"
  min_size              = 0
  name                  = "gpu-nodes-g5-4xl.k8s-dev.schlafdata.cloud"
  protect_from_scale_in = false
  tag {
    key                 = "KubernetesCluster"
    propagate_at_launch = true
    value               = "k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "gpu-nodes-g5-4xl.k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "aws-node-termination-handler/managed"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "gpus"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "instance_type"
    propagate_at_launch = true
    value               = "g5-4xl"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/instance-group"
    propagate_at_launch = true
    value               = "gpu-nodes-g5-4xl"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/role/node"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "gpu-nodes-g5-4xl"
  }
  tag {
    key                 = "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"
    propagate_at_launch = true
    value               = "owned"
  }
  tag {
    key                 = "node_type"
    propagate_at_launch = true
    value               = "gpu"
  }
  vpc_zone_identifier = ["subnet-0d40e2efbf64ff3e5"]
}

resource "aws_autoscaling_group" "gpu-nodes-g5-xl-k8s-dev-schlafdata-cloud" {
  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  launch_template {
    id      = aws_launch_template.gpu-nodes-g5-xl-k8s-dev-schlafdata-cloud.id
    version = aws_launch_template.gpu-nodes-g5-xl-k8s-dev-schlafdata-cloud.latest_version
  }
  max_instance_lifetime = 0
  max_size              = 1
  metrics_granularity   = "1Minute"
  min_size              = 0
  name                  = "gpu-nodes-g5-xl.k8s-dev.schlafdata.cloud"
  protect_from_scale_in = false
  tag {
    key                 = "KubernetesCluster"
    propagate_at_launch = true
    value               = "k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "gpu-nodes-g5-xl.k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "aws-node-termination-handler/managed"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "gpus"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "instance_type"
    propagate_at_launch = true
    value               = "g5-xl"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/instance-group"
    propagate_at_launch = true
    value               = "gpu-nodes-g5-xl"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/role/node"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "gpu-nodes-g5-xl"
  }
  tag {
    key                 = "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"
    propagate_at_launch = true
    value               = "owned"
  }
  tag {
    key                 = "node_type"
    propagate_at_launch = true
    value               = "gpu"
  }
  vpc_zone_identifier = ["subnet-0d40e2efbf64ff3e5"]
}

resource "aws_autoscaling_group" "master-us-west-2a-masters-k8s-dev-schlafdata-cloud" {
  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  launch_template {
    id      = aws_launch_template.master-us-west-2a-masters-k8s-dev-schlafdata-cloud.id
    version = aws_launch_template.master-us-west-2a-masters-k8s-dev-schlafdata-cloud.latest_version
  }
  max_instance_lifetime = 0
  max_size              = 1
  metrics_granularity   = "1Minute"
  min_size              = 1
  name                  = "master-us-west-2a.masters.k8s-dev.schlafdata.cloud"
  protect_from_scale_in = false
  tag {
    key                 = "KubernetesCluster"
    propagate_at_launch = true
    value               = "k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "master-us-west-2a.masters.k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "aws-node-termination-handler/managed"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "master-us-west-2a"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/kops-controller-pki"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/control-plane"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node.kubernetes.io/exclude-from-external-load-balancers"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/role/control-plane"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "k8s.io/role/master"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "master-us-west-2a"
  }
  tag {
    key                 = "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"
    propagate_at_launch = true
    value               = "owned"
  }
  target_group_arns   = [aws_lb_target_group.tcp-k8s-dev-schlafdata-cl-9f981s.id]
  vpc_zone_identifier = ["subnet-0d40e2efbf64ff3e5"]
}

resource "aws_autoscaling_group" "nodes-us-west-2a-k8s-dev-schlafdata-cloud" {
  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  launch_template {
    id      = aws_launch_template.nodes-us-west-2a-k8s-dev-schlafdata-cloud.id
    version = aws_launch_template.nodes-us-west-2a-k8s-dev-schlafdata-cloud.latest_version
  }
  max_instance_lifetime = 0
  max_size              = 3
  metrics_granularity   = "1Minute"
  min_size              = 1
  name                  = "nodes-us-west-2a.k8s-dev.schlafdata.cloud"
  protect_from_scale_in = false
  tag {
    key                 = "KubernetesCluster"
    propagate_at_launch = true
    value               = "k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "nodes-us-west-2a.k8s-dev.schlafdata.cloud"
  }
  tag {
    key                 = "aws-node-termination-handler/managed"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "nodes-us-west-2a"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/role/node"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "nodes-us-west-2a"
  }
  tag {
    key                 = "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"
    propagate_at_launch = true
    value               = "owned"
  }
  vpc_zone_identifier = ["subnet-0d40e2efbf64ff3e5"]
}

resource "aws_autoscaling_lifecycle_hook" "gpu-nodes-g4dn-12xl-NTHLifecycleHook" {
  autoscaling_group_name = aws_autoscaling_group.gpu-nodes-g4dn-12xl-k8s-dev-schlafdata-cloud.id
  default_result         = "CONTINUE"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  name                   = "gpu-nodes-g4dn-12xl-NTHLifecycleHook"
}

resource "aws_autoscaling_lifecycle_hook" "gpu-nodes-g4dn-2xl-NTHLifecycleHook" {
  autoscaling_group_name = aws_autoscaling_group.gpu-nodes-g4dn-2xl-k8s-dev-schlafdata-cloud.id
  default_result         = "CONTINUE"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  name                   = "gpu-nodes-g4dn-2xl-NTHLifecycleHook"
}

resource "aws_autoscaling_lifecycle_hook" "gpu-nodes-g4dn-4xl-NTHLifecycleHook" {
  autoscaling_group_name = aws_autoscaling_group.gpu-nodes-g4dn-4xl-k8s-dev-schlafdata-cloud.id
  default_result         = "CONTINUE"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  name                   = "gpu-nodes-g4dn-4xl-NTHLifecycleHook"
}

resource "aws_autoscaling_lifecycle_hook" "gpu-nodes-g4dn-xl-NTHLifecycleHook" {
  autoscaling_group_name = aws_autoscaling_group.gpu-nodes-g4dn-xl-k8s-dev-schlafdata-cloud.id
  default_result         = "CONTINUE"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  name                   = "gpu-nodes-g4dn-xl-NTHLifecycleHook"
}

resource "aws_autoscaling_lifecycle_hook" "gpu-nodes-g5-12xl-NTHLifecycleHook" {
  autoscaling_group_name = aws_autoscaling_group.gpu-nodes-g5-12xl-k8s-dev-schlafdata-cloud.id
  default_result         = "CONTINUE"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  name                   = "gpu-nodes-g5-12xl-NTHLifecycleHook"
}

resource "aws_autoscaling_lifecycle_hook" "gpu-nodes-g5-4xl-NTHLifecycleHook" {
  autoscaling_group_name = aws_autoscaling_group.gpu-nodes-g5-4xl-k8s-dev-schlafdata-cloud.id
  default_result         = "CONTINUE"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  name                   = "gpu-nodes-g5-4xl-NTHLifecycleHook"
}

resource "aws_autoscaling_lifecycle_hook" "gpu-nodes-g5-xl-NTHLifecycleHook" {
  autoscaling_group_name = aws_autoscaling_group.gpu-nodes-g5-xl-k8s-dev-schlafdata-cloud.id
  default_result         = "CONTINUE"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  name                   = "gpu-nodes-g5-xl-NTHLifecycleHook"
}

resource "aws_autoscaling_lifecycle_hook" "master-us-west-2a-NTHLifecycleHook" {
  autoscaling_group_name = aws_autoscaling_group.master-us-west-2a-masters-k8s-dev-schlafdata-cloud.id
  default_result         = "CONTINUE"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  name                   = "master-us-west-2a-NTHLifecycleHook"
}

resource "aws_autoscaling_lifecycle_hook" "nodes-us-west-2a-NTHLifecycleHook" {
  autoscaling_group_name = aws_autoscaling_group.nodes-us-west-2a-k8s-dev-schlafdata-cloud.id
  default_result         = "CONTINUE"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  name                   = "nodes-us-west-2a-NTHLifecycleHook"
}

resource "aws_cloudwatch_event_rule" "k8s-dev-schlafdata-cloud-ASGLifecycle" {
  event_pattern = file("${path.module}/data/aws_cloudwatch_event_rule_k8s-dev.schlafdata.cloud-ASGLifecycle_event_pattern")
  name          = "k8s-dev.schlafdata.cloud-ASGLifecycle"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "k8s-dev.schlafdata.cloud-ASGLifecycle"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
  }
}

resource "aws_cloudwatch_event_rule" "k8s-dev-schlafdata-cloud-InstanceScheduledChange" {
  event_pattern = file("${path.module}/data/aws_cloudwatch_event_rule_k8s-dev.schlafdata.cloud-InstanceScheduledChange_event_pattern")
  name          = "k8s-dev.schlafdata.cloud-InstanceScheduledChange"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "k8s-dev.schlafdata.cloud-InstanceScheduledChange"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
  }
}

resource "aws_cloudwatch_event_rule" "k8s-dev-schlafdata-cloud-InstanceStateChange" {
  event_pattern = file("${path.module}/data/aws_cloudwatch_event_rule_k8s-dev.schlafdata.cloud-InstanceStateChange_event_pattern")
  name          = "k8s-dev.schlafdata.cloud-InstanceStateChange"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "k8s-dev.schlafdata.cloud-InstanceStateChange"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
  }
}

resource "aws_cloudwatch_event_rule" "k8s-dev-schlafdata-cloud-SpotInterruption" {
  event_pattern = file("${path.module}/data/aws_cloudwatch_event_rule_k8s-dev.schlafdata.cloud-SpotInterruption_event_pattern")
  name          = "k8s-dev.schlafdata.cloud-SpotInterruption"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "k8s-dev.schlafdata.cloud-SpotInterruption"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
  }
}

resource "aws_cloudwatch_event_target" "k8s-dev-schlafdata-cloud-ASGLifecycle-Target" {
  arn  = aws_sqs_queue.k8s-dev-schlafdata-cloud-nth.arn
  rule = aws_cloudwatch_event_rule.k8s-dev-schlafdata-cloud-ASGLifecycle.id
}

resource "aws_cloudwatch_event_target" "k8s-dev-schlafdata-cloud-InstanceScheduledChange-Target" {
  arn  = aws_sqs_queue.k8s-dev-schlafdata-cloud-nth.arn
  rule = aws_cloudwatch_event_rule.k8s-dev-schlafdata-cloud-InstanceScheduledChange.id
}

resource "aws_cloudwatch_event_target" "k8s-dev-schlafdata-cloud-InstanceStateChange-Target" {
  arn  = aws_sqs_queue.k8s-dev-schlafdata-cloud-nth.arn
  rule = aws_cloudwatch_event_rule.k8s-dev-schlafdata-cloud-InstanceStateChange.id
}

resource "aws_cloudwatch_event_target" "k8s-dev-schlafdata-cloud-SpotInterruption-Target" {
  arn  = aws_sqs_queue.k8s-dev-schlafdata-cloud-nth.arn
  rule = aws_cloudwatch_event_rule.k8s-dev-schlafdata-cloud-SpotInterruption.id
}

resource "aws_ebs_volume" "a-etcd-events-k8s-dev-schlafdata-cloud" {
  availability_zone = "us-west-2a"
  encrypted         = true
  iops              = 3000
  size              = 20
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "a.etcd-events.k8s-dev.schlafdata.cloud"
    "k8s.io/etcd/events"                             = "a/a"
    "k8s.io/role/control-plane"                      = "1"
    "k8s.io/role/master"                             = "1"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
  }
  throughput = 125
  type       = "gp3"
}

resource "aws_ebs_volume" "a-etcd-main-k8s-dev-schlafdata-cloud" {
  availability_zone = "us-west-2a"
  encrypted         = true
  iops              = 3000
  size              = 20
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "a.etcd-main.k8s-dev.schlafdata.cloud"
    "k8s.io/etcd/main"                               = "a/a"
    "k8s.io/role/control-plane"                      = "1"
    "k8s.io/role/master"                             = "1"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
  }
  throughput = 125
  type       = "gp3"
}

resource "aws_iam_instance_profile" "masters-k8s-dev-schlafdata-cloud" {
  name = "masters.k8s-dev.schlafdata.cloud"
  role = aws_iam_role.masters-k8s-dev-schlafdata-cloud.name
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "masters.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
  }
}

resource "aws_iam_instance_profile" "nodes-k8s-dev-schlafdata-cloud" {
  name = "nodes.k8s-dev.schlafdata.cloud"
  role = aws_iam_role.nodes-k8s-dev-schlafdata-cloud.name
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "nodes.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
  }
}

resource "aws_iam_openid_connect_provider" "k8s-dev-schlafdata-cloud" {
  client_id_list = ["amazonaws.com"]
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
  }
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280", "a9d53002e97e00e043244f3d170d6f4c414104fd"]
  url             = "https://iam-http-dir-dev-schlafdata-cloud.s3.us-west-2.amazonaws.com"
}

resource "aws_iam_role" "aws-cloud-controller-manager-kube-system-sa-k8s-dev-schla-c9672l" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_aws-cloud-controller-manager.kube-system.sa.k8s-dev.schla-c9672l_policy")
  name               = "aws-cloud-controller-manager.kube-system.sa.k8s-dev.schla-c9672l"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "aws-cloud-controller-manager.kube-system.sa.k8s-dev.schla-c9672l"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
    "service-account.kops.k8s.io/name"               = "aws-cloud-controller-manager"
    "service-account.kops.k8s.io/namespace"          = "kube-system"
  }
}

resource "aws_iam_role" "aws-lb-controller-default-sa-k8s-dev-schlafdata-cloud" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_aws-lb-controller.default.sa.k8s-dev.schlafdata.cloud_policy")
  name               = "aws-lb-controller.default.sa.k8s-dev.schlafdata.cloud"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "aws-lb-controller.default.sa.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
    "service-account.kops.k8s.io/name"               = "aws-lb-controller"
    "service-account.kops.k8s.io/namespace"          = "default"
  }
}

resource "aws_iam_role" "aws-node-termination-handler-kube-system-sa-k8s-dev-schla-q8li9f" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_aws-node-termination-handler.kube-system.sa.k8s-dev.schla-q8li9f_policy")
  name               = "aws-node-termination-handler.kube-system.sa.k8s-dev.schla-q8li9f"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "aws-node-termination-handler.kube-system.sa.k8s-dev.schla-q8li9f"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
    "service-account.kops.k8s.io/name"               = "aws-node-termination-handler"
    "service-account.kops.k8s.io/namespace"          = "kube-system"
  }
}

resource "aws_iam_role" "cert-manager-kube-system-sa-k8s-dev-schlafdata-cloud" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_cert-manager.kube-system.sa.k8s-dev.schlafdata.cloud_policy")
  name               = "cert-manager.kube-system.sa.k8s-dev.schlafdata.cloud"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "cert-manager.kube-system.sa.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
    "service-account.kops.k8s.io/name"               = "cert-manager"
    "service-account.kops.k8s.io/namespace"          = "kube-system"
  }
}

resource "aws_iam_role" "cluster-autoscaler-kube-system-sa-k8s-dev-schlafdata-cloud" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_cluster-autoscaler.kube-system.sa.k8s-dev.schlafdata.cloud_policy")
  name               = "cluster-autoscaler.kube-system.sa.k8s-dev.schlafdata.cloud"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "cluster-autoscaler.kube-system.sa.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
    "service-account.kops.k8s.io/name"               = "cluster-autoscaler"
    "service-account.kops.k8s.io/namespace"          = "kube-system"
  }
}

resource "aws_iam_role" "dns-controller-kube-system-sa-k8s-dev-schlafdata-cloud" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_dns-controller.kube-system.sa.k8s-dev.schlafdata.cloud_policy")
  name               = "dns-controller.kube-system.sa.k8s-dev.schlafdata.cloud"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "dns-controller.kube-system.sa.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
    "service-account.kops.k8s.io/name"               = "dns-controller"
    "service-account.kops.k8s.io/namespace"          = "kube-system"
  }
}

resource "aws_iam_role" "ebs-csi-controller-sa-kube-system-sa-k8s-dev-schlafdata-cloud" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_ebs-csi-controller-sa.kube-system.sa.k8s-dev.schlafdata.cloud_policy")
  name               = "ebs-csi-controller-sa.kube-system.sa.k8s-dev.schlafdata.cloud"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "ebs-csi-controller-sa.kube-system.sa.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
    "service-account.kops.k8s.io/name"               = "ebs-csi-controller-sa"
    "service-account.kops.k8s.io/namespace"          = "kube-system"
  }
}

resource "aws_iam_role" "ecr-default-sa-k8s-dev-schlafdata-cloud" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_ecr.default.sa.k8s-dev.schlafdata.cloud_policy")
  name               = "ecr.default.sa.k8s-dev.schlafdata.cloud"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "ecr.default.sa.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
    "service-account.kops.k8s.io/name"               = "ecr"
    "service-account.kops.k8s.io/namespace"          = "default"
  }
}

resource "aws_iam_role" "efs-access-point-policy-default-sa-k8s-dev-schlafdata-cloud" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_efs-access-point-policy.default.sa.k8s-dev.schlafdata.cloud_policy")
  name               = "efs-access-point-policy.default.sa.k8s-dev.schlafdata.cloud"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "efs-access-point-policy.default.sa.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
    "service-account.kops.k8s.io/name"               = "efs-access-point-policy"
    "service-account.kops.k8s.io/namespace"          = "default"
  }
}

resource "aws_iam_role" "efs-csi-controller-sa-default-sa-k8s-dev-schlafdata-cloud" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_efs-csi-controller-sa.default.sa.k8s-dev.schlafdata.cloud_policy")
  name               = "efs-csi-controller-sa.default.sa.k8s-dev.schlafdata.cloud"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "efs-csi-controller-sa.default.sa.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
    "service-account.kops.k8s.io/name"               = "efs-csi-controller-sa"
    "service-account.kops.k8s.io/namespace"          = "default"
  }
}

resource "aws_iam_role" "external-dns-default-sa-k8s-dev-schlafdata-cloud" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_external-dns.default.sa.k8s-dev.schlafdata.cloud_policy")
  name               = "external-dns.default.sa.k8s-dev.schlafdata.cloud"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "external-dns.default.sa.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
    "service-account.kops.k8s.io/name"               = "external-dns"
    "service-account.kops.k8s.io/namespace"          = "default"
  }
}

resource "aws_iam_role" "kops-default-sa-k8s-dev-schlafdata-cloud" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_kops.default.sa.k8s-dev.schlafdata.cloud_policy")
  name               = "kops.default.sa.k8s-dev.schlafdata.cloud"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "kops.default.sa.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
    "service-account.kops.k8s.io/name"               = "kops"
    "service-account.kops.k8s.io/namespace"          = "default"
  }
}

resource "aws_iam_role" "masters-k8s-dev-schlafdata-cloud" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_masters.k8s-dev.schlafdata.cloud_policy")
  name               = "masters.k8s-dev.schlafdata.cloud"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "masters.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
  }
}

resource "aws_iam_role" "nodes-k8s-dev-schlafdata-cloud" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_nodes.k8s-dev.schlafdata.cloud_policy")
  name               = "nodes.k8s-dev.schlafdata.cloud"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "nodes.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
  }
}

resource "aws_iam_role_policy" "aws-cloud-controller-manager-kube-system-sa-k8s-dev-schla-c9672l" {
  name   = "aws-cloud-controller-manager.kube-system.sa.k8s-dev.schla-c9672l"
  policy = file("${path.module}/data/aws_iam_role_policy_aws-cloud-controller-manager.kube-system.sa.k8s-dev.schla-c9672l_policy")
  role   = aws_iam_role.aws-cloud-controller-manager-kube-system-sa-k8s-dev-schla-c9672l.name
}

resource "aws_iam_role_policy" "aws-node-termination-handler-kube-system-sa-k8s-dev-schla-q8li9f" {
  name   = "aws-node-termination-handler.kube-system.sa.k8s-dev.schla-q8li9f"
  policy = file("${path.module}/data/aws_iam_role_policy_aws-node-termination-handler.kube-system.sa.k8s-dev.schla-q8li9f_policy")
  role   = aws_iam_role.aws-node-termination-handler-kube-system-sa-k8s-dev-schla-q8li9f.name
}

resource "aws_iam_role_policy" "cert-manager-kube-system-sa-k8s-dev-schlafdata-cloud" {
  name   = "cert-manager.kube-system.sa.k8s-dev.schlafdata.cloud"
  policy = file("${path.module}/data/aws_iam_role_policy_cert-manager.kube-system.sa.k8s-dev.schlafdata.cloud_policy")
  role   = aws_iam_role.cert-manager-kube-system-sa-k8s-dev-schlafdata-cloud.name
}

resource "aws_iam_role_policy" "cluster-autoscaler-kube-system-sa-k8s-dev-schlafdata-cloud" {
  name   = "cluster-autoscaler.kube-system.sa.k8s-dev.schlafdata.cloud"
  policy = file("${path.module}/data/aws_iam_role_policy_cluster-autoscaler.kube-system.sa.k8s-dev.schlafdata.cloud_policy")
  role   = aws_iam_role.cluster-autoscaler-kube-system-sa-k8s-dev-schlafdata-cloud.name
}

resource "aws_iam_role_policy" "dns-controller-kube-system-sa-k8s-dev-schlafdata-cloud" {
  name   = "dns-controller.kube-system.sa.k8s-dev.schlafdata.cloud"
  policy = file("${path.module}/data/aws_iam_role_policy_dns-controller.kube-system.sa.k8s-dev.schlafdata.cloud_policy")
  role   = aws_iam_role.dns-controller-kube-system-sa-k8s-dev-schlafdata-cloud.name
}

resource "aws_iam_role_policy" "ebs-csi-controller-sa-kube-system-sa-k8s-dev-schlafdata-cloud" {
  name   = "ebs-csi-controller-sa.kube-system.sa.k8s-dev.schlafdata.cloud"
  policy = file("${path.module}/data/aws_iam_role_policy_ebs-csi-controller-sa.kube-system.sa.k8s-dev.schlafdata.cloud_policy")
  role   = aws_iam_role.ebs-csi-controller-sa-kube-system-sa-k8s-dev-schlafdata-cloud.name
}

resource "aws_iam_role_policy" "masters-k8s-dev-schlafdata-cloud" {
  name   = "masters.k8s-dev.schlafdata.cloud"
  policy = file("${path.module}/data/aws_iam_role_policy_masters.k8s-dev.schlafdata.cloud_policy")
  role   = aws_iam_role.masters-k8s-dev-schlafdata-cloud.name
}

resource "aws_iam_role_policy" "nodes-k8s-dev-schlafdata-cloud" {
  name   = "nodes.k8s-dev.schlafdata.cloud"
  policy = file("${path.module}/data/aws_iam_role_policy_nodes.k8s-dev.schlafdata.cloud_policy")
  role   = aws_iam_role.nodes-k8s-dev-schlafdata-cloud.name
}

resource "aws_iam_role_policy_attachment" "external-aws-lb-controller-default-sa-k8s-dev-schlafdata-cloud-953674697" {
  policy_arn = "arn:aws:iam::406622241617:policy/aws-lb-controller"
  role       = aws_iam_role.aws-lb-controller-default-sa-k8s-dev-schlafdata-cloud.name
}

resource "aws_iam_role_policy_attachment" "external-ecr-default-sa-k8s-dev-schlafdata-cloud-1926719714" {
  policy_arn = "arn:aws:iam::406622241617:policy/ecr"
  role       = aws_iam_role.ecr-default-sa-k8s-dev-schlafdata-cloud.name
}

resource "aws_iam_role_policy_attachment" "external-efs-access-point-policy-default-sa-k8s-dev-schlafdata-cloud-1951916667" {
  policy_arn = "arn:aws:iam::406622241617:policy/efs-access-point-policy"
  role       = aws_iam_role.efs-access-point-policy-default-sa-k8s-dev-schlafdata-cloud.name
}

resource "aws_iam_role_policy_attachment" "external-efs-csi-controller-sa-default-sa-k8s-dev-schlafdata-cloud-1695373826" {
  policy_arn = "arn:aws:iam::406622241617:policy/efs-csi-controller-sa"
  role       = aws_iam_role.efs-csi-controller-sa-default-sa-k8s-dev-schlafdata-cloud.name
}

resource "aws_iam_role_policy_attachment" "external-external-dns-default-sa-k8s-dev-schlafdata-cloud-1276784249" {
  policy_arn = "arn:aws:iam::406622241617:policy/external-dns"
  role       = aws_iam_role.external-dns-default-sa-k8s-dev-schlafdata-cloud.name
}

resource "aws_iam_role_policy_attachment" "external-kops-default-sa-k8s-dev-schlafdata-cloud-2632655111" {
  policy_arn = "arn:aws:iam::406622241617:policy/kops"
  role       = aws_iam_role.kops-default-sa-k8s-dev-schlafdata-cloud.name
}

# resource "aws_key_pair" "id_ed25519_kops" {
#   key_name   = "id_ed25519_kops"
#   public_key = file("${path.module}/data/aws_key_pair_id_ed25519_kops_public_key")
#   tags = {
#     "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
#     "Name"                                           = "k8s-dev.schlafdata.cloud"
#     "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
#   }
# }

data "aws_key_pair" "id_ed25519_kops" {
  key_name = "id_ed25519_kops"
}


resource "aws_launch_template" "gpu-nodes-g4dn-12xl-k8s-dev-schlafdata-cloud" {
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 128
      volume_type           = "gp3"
    }
  }
  block_device_mappings {
    device_name  = "/dev/sdc"
    virtual_name = "ephemeral0"
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.nodes-k8s-dev-schlafdata-cloud.id
  }
  image_id      = "ami-01b22a09b36812401"
  instance_type = "g4dn.12xlarge"
  key_name      = data.aws_key_pair.id_ed25519_kops.key_name
  lifecycle {
    create_before_destroy = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  monitoring {
    enabled = false
  }
  name = "gpu-nodes-g4dn-12xl.k8s-dev.schlafdata.cloud"
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    ipv6_address_count          = 0
    security_groups             = [aws_security_group.nodes-k8s-dev-schlafdata-cloud.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
      "Name"                                                                       = "gpu-nodes-g4dn-12xl.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                       = ""
      "gpus"                                                                       = "4"
      "instance_type"                                                              = "g4dn-12xl"
      "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g4dn-12xl"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g4dn-12xl"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
      "node_type"                                                                  = "gpu"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
      "Name"                                                                       = "gpu-nodes-g4dn-12xl.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                       = ""
      "gpus"                                                                       = "4"
      "instance_type"                                                              = "g4dn-12xl"
      "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g4dn-12xl"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g4dn-12xl"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
      "node_type"                                                                  = "gpu"
    }
  }
  tags = {
    "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
    "Name"                                                                       = "gpu-nodes-g4dn-12xl.k8s-dev.schlafdata.cloud"
    "aws-node-termination-handler/managed"                                       = ""
    "gpus"                                                                       = "4"
    "instance_type"                                                              = "g4dn-12xl"
    "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g4dn-12xl"
    "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
    "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
    "k8s.io/role/node"                                                           = "1"
    "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g4dn-12xl"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
    "node_type"                                                                  = "gpu"
  }
  user_data = filebase64("${path.module}/data/aws_launch_template_gpu-nodes-g4dn-12xl.k8s-dev.schlafdata.cloud_user_data")
}

resource "aws_launch_template" "gpu-nodes-g4dn-2xl-k8s-dev-schlafdata-cloud" {
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 128
      volume_type           = "gp3"
    }
  }
  block_device_mappings {
    device_name  = "/dev/sdc"
    virtual_name = "ephemeral0"
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.nodes-k8s-dev-schlafdata-cloud.id
  }
  image_id      = "ami-01b22a09b36812401"
  instance_type = "g4dn.2xlarge"
  key_name      = data.aws_key_pair.id_ed25519_kops.key_name
  lifecycle {
    create_before_destroy = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  monitoring {
    enabled = false
  }
  name = "gpu-nodes-g4dn-2xl.k8s-dev.schlafdata.cloud"
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    ipv6_address_count          = 0
    security_groups             = [aws_security_group.nodes-k8s-dev-schlafdata-cloud.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
      "Name"                                                                       = "gpu-nodes-g4dn-2xl.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                       = ""
      "gpus"                                                                       = "1"
      "instance_type"                                                              = "g4dn-2xl"
      "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g4dn-2xl"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g4dn-2xl"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
      "node_type"                                                                  = "gpu"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
      "Name"                                                                       = "gpu-nodes-g4dn-2xl.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                       = ""
      "gpus"                                                                       = "1"
      "instance_type"                                                              = "g4dn-2xl"
      "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g4dn-2xl"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g4dn-2xl"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
      "node_type"                                                                  = "gpu"
    }
  }
  tags = {
    "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
    "Name"                                                                       = "gpu-nodes-g4dn-2xl.k8s-dev.schlafdata.cloud"
    "aws-node-termination-handler/managed"                                       = ""
    "gpus"                                                                       = "1"
    "instance_type"                                                              = "g4dn-2xl"
    "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g4dn-2xl"
    "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
    "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
    "k8s.io/role/node"                                                           = "1"
    "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g4dn-2xl"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
    "node_type"                                                                  = "gpu"
  }
  user_data = filebase64("${path.module}/data/aws_launch_template_gpu-nodes-g4dn-2xl.k8s-dev.schlafdata.cloud_user_data")
}

resource "aws_launch_template" "gpu-nodes-g4dn-4xl-k8s-dev-schlafdata-cloud" {
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 128
      volume_type           = "gp3"
    }
  }
  block_device_mappings {
    device_name  = "/dev/sdc"
    virtual_name = "ephemeral0"
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.nodes-k8s-dev-schlafdata-cloud.id
  }
  image_id      = "ami-01b22a09b36812401"
  instance_type = "g4dn.4xlarge"
  key_name      = data.aws_key_pair.id_ed25519_kops.key_name
  lifecycle {
    create_before_destroy = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  monitoring {
    enabled = false
  }
  name = "gpu-nodes-g4dn-4xl.k8s-dev.schlafdata.cloud"
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    ipv6_address_count          = 0
    security_groups             = [aws_security_group.nodes-k8s-dev-schlafdata-cloud.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
      "Name"                                                                       = "gpu-nodes-g4dn-4xl.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                       = ""
      "gpus"                                                                       = "1"
      "instance_type"                                                              = "g4dn-4xl"
      "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g4dn-4xl"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g4dn-4xl"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
      "node_type"                                                                  = "gpu"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
      "Name"                                                                       = "gpu-nodes-g4dn-4xl.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                       = ""
      "gpus"                                                                       = "1"
      "instance_type"                                                              = "g4dn-4xl"
      "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g4dn-4xl"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g4dn-4xl"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
      "node_type"                                                                  = "gpu"
    }
  }
  tags = {
    "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
    "Name"                                                                       = "gpu-nodes-g4dn-4xl.k8s-dev.schlafdata.cloud"
    "aws-node-termination-handler/managed"                                       = ""
    "gpus"                                                                       = "1"
    "instance_type"                                                              = "g4dn-4xl"
    "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g4dn-4xl"
    "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
    "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
    "k8s.io/role/node"                                                           = "1"
    "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g4dn-4xl"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
    "node_type"                                                                  = "gpu"
  }
  user_data = filebase64("${path.module}/data/aws_launch_template_gpu-nodes-g4dn-4xl.k8s-dev.schlafdata.cloud_user_data")
}

resource "aws_launch_template" "gpu-nodes-g4dn-xl-k8s-dev-schlafdata-cloud" {
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 128
      volume_type           = "gp3"
    }
  }
  block_device_mappings {
    device_name  = "/dev/sdc"
    virtual_name = "ephemeral0"
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.nodes-k8s-dev-schlafdata-cloud.id
  }
  image_id      = "ami-01b22a09b36812401"
  instance_type = "g4dn.xlarge"
  key_name      = data.aws_key_pair.id_ed25519_kops.key_name
  lifecycle {
    create_before_destroy = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  monitoring {
    enabled = false
  }
  name = "gpu-nodes-g4dn-xl.k8s-dev.schlafdata.cloud"
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    ipv6_address_count          = 0
    security_groups             = [aws_security_group.nodes-k8s-dev-schlafdata-cloud.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
      "Name"                                                                       = "gpu-nodes-g4dn-xl.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                       = ""
      "gpus"                                                                       = "1"
      "instance_type"                                                              = "g4dn-xl"
      "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g4dn-xl"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g4dn-xl"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
      "node_type"                                                                  = "gpu"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
      "Name"                                                                       = "gpu-nodes-g4dn-xl.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                       = ""
      "gpus"                                                                       = "1"
      "instance_type"                                                              = "g4dn-xl"
      "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g4dn-xl"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g4dn-xl"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
      "node_type"                                                                  = "gpu"
    }
  }
  tags = {
    "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
    "Name"                                                                       = "gpu-nodes-g4dn-xl.k8s-dev.schlafdata.cloud"
    "aws-node-termination-handler/managed"                                       = ""
    "gpus"                                                                       = "1"
    "instance_type"                                                              = "g4dn-xl"
    "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g4dn-xl"
    "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
    "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
    "k8s.io/role/node"                                                           = "1"
    "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g4dn-xl"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
    "node_type"                                                                  = "gpu"
  }
  user_data = filebase64("${path.module}/data/aws_launch_template_gpu-nodes-g4dn-xl.k8s-dev.schlafdata.cloud_user_data")
}

resource "aws_launch_template" "gpu-nodes-g5-12xl-k8s-dev-schlafdata-cloud" {
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 128
      volume_type           = "gp3"
    }
  }
  block_device_mappings {
    device_name  = "/dev/sdc"
    virtual_name = "ephemeral0"
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.nodes-k8s-dev-schlafdata-cloud.id
  }
  image_id      = "ami-01b22a09b36812401"
  instance_type = "g5.12xlarge"
  key_name      = data.aws_key_pair.id_ed25519_kops.key_name
  lifecycle {
    create_before_destroy = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  monitoring {
    enabled = false
  }
  name = "gpu-nodes-g5-12xl.k8s-dev.schlafdata.cloud"
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    ipv6_address_count          = 0
    security_groups             = [aws_security_group.nodes-k8s-dev-schlafdata-cloud.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
      "Name"                                                                       = "gpu-nodes-g5-12xl.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                       = ""
      "gpus"                                                                       = "4"
      "instance_type"                                                              = "g5-12xl"
      "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g5-12xl"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g5-12xl"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
      "node_type"                                                                  = "gpu"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
      "Name"                                                                       = "gpu-nodes-g5-12xl.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                       = ""
      "gpus"                                                                       = "4"
      "instance_type"                                                              = "g5-12xl"
      "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g5-12xl"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g5-12xl"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
      "node_type"                                                                  = "gpu"
    }
  }
  tags = {
    "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
    "Name"                                                                       = "gpu-nodes-g5-12xl.k8s-dev.schlafdata.cloud"
    "aws-node-termination-handler/managed"                                       = ""
    "gpus"                                                                       = "4"
    "instance_type"                                                              = "g5-12xl"
    "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g5-12xl"
    "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
    "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
    "k8s.io/role/node"                                                           = "1"
    "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g5-12xl"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
    "node_type"                                                                  = "gpu"
  }
  user_data = filebase64("${path.module}/data/aws_launch_template_gpu-nodes-g5-12xl.k8s-dev.schlafdata.cloud_user_data")
}

resource "aws_launch_template" "gpu-nodes-g5-4xl-k8s-dev-schlafdata-cloud" {
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 128
      volume_type           = "gp3"
    }
  }
  block_device_mappings {
    device_name  = "/dev/sdc"
    virtual_name = "ephemeral0"
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.nodes-k8s-dev-schlafdata-cloud.id
  }
  image_id      = "ami-01b22a09b36812401"
  instance_type = "g5.4xlarge"
  key_name      = data.aws_key_pair.id_ed25519_kops.key_name
  lifecycle {
    create_before_destroy = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  monitoring {
    enabled = false
  }
  name = "gpu-nodes-g5-4xl.k8s-dev.schlafdata.cloud"
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    ipv6_address_count          = 0
    security_groups             = [aws_security_group.nodes-k8s-dev-schlafdata-cloud.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
      "Name"                                                                       = "gpu-nodes-g5-4xl.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                       = ""
      "gpus"                                                                       = "1"
      "instance_type"                                                              = "g5-4xl"
      "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g5-4xl"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g5-4xl"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
      "node_type"                                                                  = "gpu"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
      "Name"                                                                       = "gpu-nodes-g5-4xl.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                       = ""
      "gpus"                                                                       = "1"
      "instance_type"                                                              = "g5-4xl"
      "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g5-4xl"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g5-4xl"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
      "node_type"                                                                  = "gpu"
    }
  }
  tags = {
    "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
    "Name"                                                                       = "gpu-nodes-g5-4xl.k8s-dev.schlafdata.cloud"
    "aws-node-termination-handler/managed"                                       = ""
    "gpus"                                                                       = "1"
    "instance_type"                                                              = "g5-4xl"
    "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g5-4xl"
    "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
    "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
    "k8s.io/role/node"                                                           = "1"
    "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g5-4xl"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
    "node_type"                                                                  = "gpu"
  }
  user_data = filebase64("${path.module}/data/aws_launch_template_gpu-nodes-g5-4xl.k8s-dev.schlafdata.cloud_user_data")
}

resource "aws_launch_template" "gpu-nodes-g5-xl-k8s-dev-schlafdata-cloud" {
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 128
      volume_type           = "gp3"
    }
  }
  block_device_mappings {
    device_name  = "/dev/sdc"
    virtual_name = "ephemeral0"
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.nodes-k8s-dev-schlafdata-cloud.id
  }
  image_id      = "ami-01b22a09b36812401"
  instance_type = "g5.xlarge"
  key_name      = data.aws_key_pair.id_ed25519_kops.key_name
  lifecycle {
    create_before_destroy = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  monitoring {
    enabled = false
  }
  name = "gpu-nodes-g5-xl.k8s-dev.schlafdata.cloud"
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    ipv6_address_count          = 0
    security_groups             = [aws_security_group.nodes-k8s-dev-schlafdata-cloud.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
      "Name"                                                                       = "gpu-nodes-g5-xl.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                       = ""
      "gpus"                                                                       = "1"
      "instance_type"                                                              = "g5-xl"
      "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g5-xl"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g5-xl"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
      "node_type"                                                                  = "gpu"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
      "Name"                                                                       = "gpu-nodes-g5-xl.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                       = ""
      "gpus"                                                                       = "1"
      "instance_type"                                                              = "g5-xl"
      "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g5-xl"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g5-xl"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
      "node_type"                                                                  = "gpu"
    }
  }
  tags = {
    "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
    "Name"                                                                       = "gpu-nodes-g5-xl.k8s-dev.schlafdata.cloud"
    "aws-node-termination-handler/managed"                                       = ""
    "gpus"                                                                       = "1"
    "instance_type"                                                              = "g5-xl"
    "k8s.io/cluster-autoscaler/node-template/label/instance-group"               = "gpu-nodes-g5-xl"
    "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/gpu"              = "1"
    "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
    "k8s.io/role/node"                                                           = "1"
    "kops.k8s.io/instancegroup"                                                  = "gpu-nodes-g5-xl"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
    "node_type"                                                                  = "gpu"
  }
  user_data = filebase64("${path.module}/data/aws_launch_template_gpu-nodes-g5-xl.k8s-dev.schlafdata.cloud_user_data")
}

resource "aws_launch_template" "master-us-west-2a-masters-k8s-dev-schlafdata-cloud" {
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 64
      volume_type           = "gp3"
    }
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.masters-k8s-dev-schlafdata-cloud.id
  }
  image_id      = "ami-01b22a09b36812401"
  instance_type = "m5.large"
  key_name      = data.aws_key_pair.id_ed25519_kops.key_name
  lifecycle {
    create_before_destroy = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  monitoring {
    enabled = false
  }
  name = "master-us-west-2a.masters.k8s-dev.schlafdata.cloud"
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    ipv6_address_count          = 0
    security_groups             = [aws_security_group.masters-k8s-dev-schlafdata-cloud.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "KubernetesCluster"                                                                                     = "k8s-dev.schlafdata.cloud"
      "Name"                                                                                                  = "master-us-west-2a.masters.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                                                  = ""
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"                               = "master-us-west-2a"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/kops-controller-pki"                         = ""
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/control-plane"                   = ""
      "k8s.io/cluster-autoscaler/node-template/label/node.kubernetes.io/exclude-from-external-load-balancers" = ""
      "k8s.io/role/control-plane"                                                                             = "1"
      "k8s.io/role/master"                                                                                    = "1"
      "kops.k8s.io/instancegroup"                                                                             = "master-us-west-2a"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                                                        = "owned"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      "KubernetesCluster"                                                                                     = "k8s-dev.schlafdata.cloud"
      "Name"                                                                                                  = "master-us-west-2a.masters.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                                                  = ""
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"                               = "master-us-west-2a"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/kops-controller-pki"                         = ""
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/control-plane"                   = ""
      "k8s.io/cluster-autoscaler/node-template/label/node.kubernetes.io/exclude-from-external-load-balancers" = ""
      "k8s.io/role/control-plane"                                                                             = "1"
      "k8s.io/role/master"                                                                                    = "1"
      "kops.k8s.io/instancegroup"                                                                             = "master-us-west-2a"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                                                        = "owned"
    }
  }
  tags = {
    "KubernetesCluster"                                                                                     = "k8s-dev.schlafdata.cloud"
    "Name"                                                                                                  = "master-us-west-2a.masters.k8s-dev.schlafdata.cloud"
    "aws-node-termination-handler/managed"                                                                  = ""
    "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"                               = "master-us-west-2a"
    "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/kops-controller-pki"                         = ""
    "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/control-plane"                   = ""
    "k8s.io/cluster-autoscaler/node-template/label/node.kubernetes.io/exclude-from-external-load-balancers" = ""
    "k8s.io/role/control-plane"                                                                             = "1"
    "k8s.io/role/master"                                                                                    = "1"
    "kops.k8s.io/instancegroup"                                                                             = "master-us-west-2a"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                                                        = "owned"
  }
  user_data = filebase64("${path.module}/data/aws_launch_template_master-us-west-2a.masters.k8s-dev.schlafdata.cloud_user_data")
}

resource "aws_launch_template" "nodes-us-west-2a-k8s-dev-schlafdata-cloud" {
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 128
      volume_type           = "gp3"
    }
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.nodes-k8s-dev-schlafdata-cloud.id
  }
  image_id      = "ami-01b22a09b36812401"
  instance_type = "m5.large"
  key_name      = data.aws_key_pair.id_ed25519_kops.key_name
  lifecycle {
    create_before_destroy = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  monitoring {
    enabled = false
  }
  name = "nodes-us-west-2a.k8s-dev.schlafdata.cloud"
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    ipv6_address_count          = 0
    security_groups             = [aws_security_group.nodes-k8s-dev-schlafdata-cloud.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
      "Name"                                                                       = "nodes-us-west-2a.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                       = ""
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"    = "nodes-us-west-2a"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "nodes-us-west-2a"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
      "Name"                                                                       = "nodes-us-west-2a.k8s-dev.schlafdata.cloud"
      "aws-node-termination-handler/managed"                                       = ""
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"    = "nodes-us-west-2a"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "nodes-us-west-2a"
      "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
    }
  }
  tags = {
    "KubernetesCluster"                                                          = "k8s-dev.schlafdata.cloud"
    "Name"                                                                       = "nodes-us-west-2a.k8s-dev.schlafdata.cloud"
    "aws-node-termination-handler/managed"                                       = ""
    "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"    = "nodes-us-west-2a"
    "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
    "k8s.io/role/node"                                                           = "1"
    "kops.k8s.io/instancegroup"                                                  = "nodes-us-west-2a"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud"                             = "owned"
  }
  user_data = filebase64("${path.module}/data/aws_launch_template_nodes-us-west-2a.k8s-dev.schlafdata.cloud_user_data")
}

resource "aws_lb" "api-k8s-dev-schlafdata-cloud" {
  enable_cross_zone_load_balancing = true
  internal                         = true
  load_balancer_type               = "network"
  name                             = "api-k8s-dev-schlafdata-cl-77esai"
  subnet_mapping {
    subnet_id = "subnet-0d40e2efbf64ff3e5"
  }
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "api.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
  }
}

resource "aws_lb_listener" "api-k8s-dev-schlafdata-cloud-443" {
  default_action {
    target_group_arn = aws_lb_target_group.tcp-k8s-dev-schlafdata-cl-9f981s.id
    type             = "forward"
  }
  load_balancer_arn = aws_lb.api-k8s-dev-schlafdata-cloud.id
  port              = 443
  protocol          = "TCP"
}

resource "aws_lb_target_group" "tcp-k8s-dev-schlafdata-cl-9f981s" {
  connection_termination = "true"
  deregistration_delay   = "30"
  health_check {
    healthy_threshold   = 2
    interval            = 10
    protocol            = "TCP"
    unhealthy_threshold = 2
  }
  name     = "tcp-k8s-dev-schlafdata-cl-9f981s"
  port     = 443
  protocol = "TCP"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "tcp-k8s-dev-schlafdata-cl-9f981s"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
  }
  vpc_id = "vpc-0b5087f6bdafd0497"
}

resource "aws_route53_record" "k8s-dev-schlafdata-cloud" {
  alias {
    evaluate_target_health = false
    name                   = aws_lb.api-k8s-dev-schlafdata-cloud.dns_name
    zone_id                = aws_lb.api-k8s-dev-schlafdata-cloud.zone_id
  }
  name    = "k8s-dev.schlafdata.cloud"
  type    = "A"
  zone_id = "/hostedzone/Z073043915ZSR6Y60ZWLQ"
}

resource "aws_route53_record" "k8s-dev-schlafdata-cloud-AAAA" {
  alias {
    evaluate_target_health = false
    name                   = aws_lb.api-k8s-dev-schlafdata-cloud.dns_name
    zone_id                = aws_lb.api-k8s-dev-schlafdata-cloud.zone_id
  }
  name    = "k8s-dev.schlafdata.cloud"
  type    = "AAAA"
  zone_id = "/hostedzone/Z073043915ZSR6Y60ZWLQ"
}

resource "aws_s3_object" "cluster-completed-spec" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_cluster-completed.spec_content")
  key      = "k8s-dev.schlafdata.cloud/cluster-completed.spec"
  provider = aws.files
}

resource "aws_s3_object" "discovery-json" {
  acl      = "public-read"
  bucket   = "iam-http-dir-dev-schlafdata-cloud"
  content  = file("${path.module}/data/aws_s3_object_discovery.json_content")
  key      = ".well-known/openid-configuration"
  provider = aws.files
}

resource "aws_s3_object" "etcd-cluster-spec-events" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_etcd-cluster-spec-events_content")
  key      = "k8s-dev.schlafdata.cloud/backups/etcd/events/control/etcd-cluster-spec"
  provider = aws.files
}

resource "aws_s3_object" "etcd-cluster-spec-main" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_etcd-cluster-spec-main_content")
  key      = "k8s-dev.schlafdata.cloud/backups/etcd/main/control/etcd-cluster-spec"
  provider = aws.files
}

resource "aws_s3_object" "k8s-dev-schlafdata-cloud-addons-aws-cloud-controller-addons-k8s-io-k8s-1-18" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_k8s-dev.schlafdata.cloud-addons-aws-cloud-controller.addons.k8s.io-k8s-1.18_content")
  key      = "k8s-dev.schlafdata.cloud/addons/aws-cloud-controller.addons.k8s.io/k8s-1.18.yaml"
  provider = aws.files
}

resource "aws_s3_object" "k8s-dev-schlafdata-cloud-addons-aws-ebs-csi-driver-addons-k8s-io-k8s-1-17" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_k8s-dev.schlafdata.cloud-addons-aws-ebs-csi-driver.addons.k8s.io-k8s-1.17_content")
  key      = "k8s-dev.schlafdata.cloud/addons/aws-ebs-csi-driver.addons.k8s.io/k8s-1.17.yaml"
  provider = aws.files
}

resource "aws_s3_object" "k8s-dev-schlafdata-cloud-addons-bootstrap" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_k8s-dev.schlafdata.cloud-addons-bootstrap_content")
  key      = "k8s-dev.schlafdata.cloud/addons/bootstrap-channel.yaml"
  provider = aws.files
}

resource "aws_s3_object" "k8s-dev-schlafdata-cloud-addons-certmanager-io-k8s-1-16" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_k8s-dev.schlafdata.cloud-addons-certmanager.io-k8s-1.16_content")
  key      = "k8s-dev.schlafdata.cloud/addons/certmanager.io/k8s-1.16.yaml"
  provider = aws.files
}

resource "aws_s3_object" "k8s-dev-schlafdata-cloud-addons-cluster-autoscaler-addons-k8s-io-k8s-1-15" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_k8s-dev.schlafdata.cloud-addons-cluster-autoscaler.addons.k8s.io-k8s-1.15_content")
  key      = "k8s-dev.schlafdata.cloud/addons/cluster-autoscaler.addons.k8s.io/k8s-1.15.yaml"
  provider = aws.files
}

resource "aws_s3_object" "k8s-dev-schlafdata-cloud-addons-coredns-addons-k8s-io-k8s-1-12" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_k8s-dev.schlafdata.cloud-addons-coredns.addons.k8s.io-k8s-1.12_content")
  key      = "k8s-dev.schlafdata.cloud/addons/coredns.addons.k8s.io/k8s-1.12.yaml"
  provider = aws.files
}

resource "aws_s3_object" "k8s-dev-schlafdata-cloud-addons-dns-controller-addons-k8s-io-k8s-1-12" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_k8s-dev.schlafdata.cloud-addons-dns-controller.addons.k8s.io-k8s-1.12_content")
  key      = "k8s-dev.schlafdata.cloud/addons/dns-controller.addons.k8s.io/k8s-1.12.yaml"
  provider = aws.files
}

resource "aws_s3_object" "k8s-dev-schlafdata-cloud-addons-eks-pod-identity-webhook-addons-k8s-io-k8s-1-16" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_k8s-dev.schlafdata.cloud-addons-eks-pod-identity-webhook.addons.k8s.io-k8s-1.16_content")
  key      = "k8s-dev.schlafdata.cloud/addons/eks-pod-identity-webhook.addons.k8s.io/k8s-1.16.yaml"
  provider = aws.files
}

resource "aws_s3_object" "k8s-dev-schlafdata-cloud-addons-kops-controller-addons-k8s-io-k8s-1-16" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_k8s-dev.schlafdata.cloud-addons-kops-controller.addons.k8s.io-k8s-1.16_content")
  key      = "k8s-dev.schlafdata.cloud/addons/kops-controller.addons.k8s.io/k8s-1.16.yaml"
  provider = aws.files
}

resource "aws_s3_object" "k8s-dev-schlafdata-cloud-addons-kubelet-api-rbac-addons-k8s-io-k8s-1-9" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_k8s-dev.schlafdata.cloud-addons-kubelet-api.rbac.addons.k8s.io-k8s-1.9_content")
  key      = "k8s-dev.schlafdata.cloud/addons/kubelet-api.rbac.addons.k8s.io/k8s-1.9.yaml"
  provider = aws.files
}

resource "aws_s3_object" "k8s-dev-schlafdata-cloud-addons-limit-range-addons-k8s-io" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_k8s-dev.schlafdata.cloud-addons-limit-range.addons.k8s.io_content")
  key      = "k8s-dev.schlafdata.cloud/addons/limit-range.addons.k8s.io/v1.5.0.yaml"
  provider = aws.files
}

resource "aws_s3_object" "k8s-dev-schlafdata-cloud-addons-networking-projectcalico-org-k8s-1-25" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_k8s-dev.schlafdata.cloud-addons-networking.projectcalico.org-k8s-1.25_content")
  key      = "k8s-dev.schlafdata.cloud/addons/networking.projectcalico.org/k8s-1.25.yaml"
  provider = aws.files
}

resource "aws_s3_object" "k8s-dev-schlafdata-cloud-addons-node-termination-handler-aws-k8s-1-11" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_k8s-dev.schlafdata.cloud-addons-node-termination-handler.aws-k8s-1.11_content")
  key      = "k8s-dev.schlafdata.cloud/addons/node-termination-handler.aws/k8s-1.11.yaml"
  provider = aws.files
}

resource "aws_s3_object" "k8s-dev-schlafdata-cloud-addons-nodelocaldns-addons-k8s-io-k8s-1-12" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_k8s-dev.schlafdata.cloud-addons-nodelocaldns.addons.k8s.io-k8s-1.12_content")
  key      = "k8s-dev.schlafdata.cloud/addons/nodelocaldns.addons.k8s.io/k8s-1.12.yaml"
  provider = aws.files
}

resource "aws_s3_object" "k8s-dev-schlafdata-cloud-addons-nvidia-addons-k8s-io-k8s-1-16" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_k8s-dev.schlafdata.cloud-addons-nvidia.addons.k8s.io-k8s-1.16_content")
  key      = "k8s-dev.schlafdata.cloud/addons/nvidia.addons.k8s.io/k8s-1.16.yaml"
  provider = aws.files
}

resource "aws_s3_object" "k8s-dev-schlafdata-cloud-addons-storage-aws-addons-k8s-io-v1-15-0" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_k8s-dev.schlafdata.cloud-addons-storage-aws.addons.k8s.io-v1.15.0_content")
  key      = "k8s-dev.schlafdata.cloud/addons/storage-aws.addons.k8s.io/v1.15.0.yaml"
  provider = aws.files
}

resource "aws_s3_object" "keys-json" {
  acl      = "public-read"
  bucket   = "iam-http-dir-dev-schlafdata-cloud"
  content  = file("${path.module}/data/aws_s3_object_keys.json_content")
  key      = "openid/v1/jwks"
  provider = aws.files
}

resource "aws_s3_object" "kops-version-txt" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_kops-version.txt_content")
  key      = "k8s-dev.schlafdata.cloud/kops-version.txt"
  provider = aws.files
}

resource "aws_s3_object" "manifests-etcdmanager-events-master-us-west-2a" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_manifests-etcdmanager-events-master-us-west-2a_content")
  key      = "k8s-dev.schlafdata.cloud/manifests/etcd/events-master-us-west-2a.yaml"
  provider = aws.files
}

resource "aws_s3_object" "manifests-etcdmanager-main-master-us-west-2a" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_manifests-etcdmanager-main-master-us-west-2a_content")
  key      = "k8s-dev.schlafdata.cloud/manifests/etcd/main-master-us-west-2a.yaml"
  provider = aws.files
}

resource "aws_s3_object" "manifests-static-kube-apiserver-healthcheck" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_manifests-static-kube-apiserver-healthcheck_content")
  key      = "k8s-dev.schlafdata.cloud/manifests/static/kube-apiserver-healthcheck.yaml"
  provider = aws.files
}

resource "aws_s3_object" "nodeupconfig-gpu-nodes-g4dn-12xl" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_nodeupconfig-gpu-nodes-g4dn-12xl_content")
  key      = "k8s-dev.schlafdata.cloud/igconfig/node/gpu-nodes-g4dn-12xl/nodeupconfig.yaml"
  provider = aws.files
}

resource "aws_s3_object" "nodeupconfig-gpu-nodes-g4dn-2xl" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_nodeupconfig-gpu-nodes-g4dn-2xl_content")
  key      = "k8s-dev.schlafdata.cloud/igconfig/node/gpu-nodes-g4dn-2xl/nodeupconfig.yaml"
  provider = aws.files
}

resource "aws_s3_object" "nodeupconfig-gpu-nodes-g4dn-4xl" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_nodeupconfig-gpu-nodes-g4dn-4xl_content")
  key      = "k8s-dev.schlafdata.cloud/igconfig/node/gpu-nodes-g4dn-4xl/nodeupconfig.yaml"
  provider = aws.files
}

resource "aws_s3_object" "nodeupconfig-gpu-nodes-g4dn-xl" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_nodeupconfig-gpu-nodes-g4dn-xl_content")
  key      = "k8s-dev.schlafdata.cloud/igconfig/node/gpu-nodes-g4dn-xl/nodeupconfig.yaml"
  provider = aws.files
}

resource "aws_s3_object" "nodeupconfig-gpu-nodes-g5-12xl" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_nodeupconfig-gpu-nodes-g5-12xl_content")
  key      = "k8s-dev.schlafdata.cloud/igconfig/node/gpu-nodes-g5-12xl/nodeupconfig.yaml"
  provider = aws.files
}

resource "aws_s3_object" "nodeupconfig-gpu-nodes-g5-4xl" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_nodeupconfig-gpu-nodes-g5-4xl_content")
  key      = "k8s-dev.schlafdata.cloud/igconfig/node/gpu-nodes-g5-4xl/nodeupconfig.yaml"
  provider = aws.files
}

resource "aws_s3_object" "nodeupconfig-gpu-nodes-g5-xl" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_nodeupconfig-gpu-nodes-g5-xl_content")
  key      = "k8s-dev.schlafdata.cloud/igconfig/node/gpu-nodes-g5-xl/nodeupconfig.yaml"
  provider = aws.files
}

resource "aws_s3_object" "nodeupconfig-master-us-west-2a" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_nodeupconfig-master-us-west-2a_content")
  key      = "k8s-dev.schlafdata.cloud/igconfig/control-plane/master-us-west-2a/nodeupconfig.yaml"
  provider = aws.files
}

resource "aws_s3_object" "nodeupconfig-nodes-us-west-2a" {
  bucket   = "kops-dev.schlafdata.cloud"
  content  = file("${path.module}/data/aws_s3_object_nodeupconfig-nodes-us-west-2a_content")
  key      = "k8s-dev.schlafdata.cloud/igconfig/node/nodes-us-west-2a/nodeupconfig.yaml"
  provider = aws.files
}

resource "aws_security_group" "api-elb-k8s-dev-schlafdata-cloud" {
  description = "Security group for api ELB"
  name        = "api-elb.k8s-dev.schlafdata.cloud"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "api-elb.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
  }
  vpc_id = "vpc-0b5087f6bdafd0497"
}

resource "aws_security_group" "masters-k8s-dev-schlafdata-cloud" {
  description = "Security group for masters"
  name        = "masters.k8s-dev.schlafdata.cloud"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "masters.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
  }
  vpc_id = "vpc-0b5087f6bdafd0497"
}

resource "aws_security_group" "nodes-k8s-dev-schlafdata-cloud" {
  description = "Security group for nodes"
  name        = "nodes.k8s-dev.schlafdata.cloud"
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "nodes.k8s-dev.schlafdata.cloud"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
  }
  vpc_id = "vpc-0b5087f6bdafd0497"
}

resource "aws_security_group_rule" "from-10-8-0-0--24-ingress-tcp-22to22-masters-k8s-dev-schlafdata-cloud" {
  cidr_blocks       = ["10.8.0.0/24"]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.masters-k8s-dev-schlafdata-cloud.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "from-10-8-0-0--24-ingress-tcp-22to22-nodes-k8s-dev-schlafdata-cloud" {
  cidr_blocks       = ["10.8.0.0/24"]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.nodes-k8s-dev-schlafdata-cloud.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "from-10-8-0-0--24-ingress-tcp-443to443-masters-k8s-dev-schlafdata-cloud" {
  cidr_blocks       = ["10.8.0.0/24"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.masters-k8s-dev-schlafdata-cloud.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "from-174-64-0-0--16-ingress-tcp-22to22-masters-k8s-dev-schlafdata-cloud" {
  cidr_blocks       = ["174.64.0.0/16"]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.masters-k8s-dev-schlafdata-cloud.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "from-174-64-0-0--16-ingress-tcp-22to22-nodes-k8s-dev-schlafdata-cloud" {
  cidr_blocks       = ["174.64.0.0/16"]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.nodes-k8s-dev-schlafdata-cloud.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "from-masters-k8s-dev-schlafdata-cloud-egress-all-0to0-0-0-0-0--0" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.masters-k8s-dev-schlafdata-cloud.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "from-masters-k8s-dev-schlafdata-cloud-egress-all-0to0-__--0" {
  from_port         = 0
  ipv6_cidr_blocks  = ["::/0"]
  protocol          = "-1"
  security_group_id = aws_security_group.masters-k8s-dev-schlafdata-cloud.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "from-masters-k8s-dev-schlafdata-cloud-ingress-all-0to0-masters-k8s-dev-schlafdata-cloud" {
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.masters-k8s-dev-schlafdata-cloud.id
  source_security_group_id = aws_security_group.masters-k8s-dev-schlafdata-cloud.id
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-masters-k8s-dev-schlafdata-cloud-ingress-all-0to0-nodes-k8s-dev-schlafdata-cloud" {
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nodes-k8s-dev-schlafdata-cloud.id
  source_security_group_id = aws_security_group.masters-k8s-dev-schlafdata-cloud.id
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-k8s-dev-schlafdata-cloud-egress-all-0to0-0-0-0-0--0" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.nodes-k8s-dev-schlafdata-cloud.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "from-nodes-k8s-dev-schlafdata-cloud-egress-all-0to0-__--0" {
  from_port         = 0
  ipv6_cidr_blocks  = ["::/0"]
  protocol          = "-1"
  security_group_id = aws_security_group.nodes-k8s-dev-schlafdata-cloud.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "from-nodes-k8s-dev-schlafdata-cloud-ingress-4-0to0-masters-k8s-dev-schlafdata-cloud" {
  from_port                = 0
  protocol                 = "4"
  security_group_id        = aws_security_group.masters-k8s-dev-schlafdata-cloud.id
  source_security_group_id = aws_security_group.nodes-k8s-dev-schlafdata-cloud.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-k8s-dev-schlafdata-cloud-ingress-all-0to0-nodes-k8s-dev-schlafdata-cloud" {
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nodes-k8s-dev-schlafdata-cloud.id
  source_security_group_id = aws_security_group.nodes-k8s-dev-schlafdata-cloud.id
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-k8s-dev-schlafdata-cloud-ingress-tcp-1to2379-masters-k8s-dev-schlafdata-cloud" {
  from_port                = 1
  protocol                 = "tcp"
  security_group_id        = aws_security_group.masters-k8s-dev-schlafdata-cloud.id
  source_security_group_id = aws_security_group.nodes-k8s-dev-schlafdata-cloud.id
  to_port                  = 2379
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-k8s-dev-schlafdata-cloud-ingress-tcp-2382to4000-masters-k8s-dev-schlafdata-cloud" {
  from_port                = 2382
  protocol                 = "tcp"
  security_group_id        = aws_security_group.masters-k8s-dev-schlafdata-cloud.id
  source_security_group_id = aws_security_group.nodes-k8s-dev-schlafdata-cloud.id
  to_port                  = 4000
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-k8s-dev-schlafdata-cloud-ingress-tcp-4003to65535-masters-k8s-dev-schlafdata-cloud" {
  from_port                = 4003
  protocol                 = "tcp"
  security_group_id        = aws_security_group.masters-k8s-dev-schlafdata-cloud.id
  source_security_group_id = aws_security_group.nodes-k8s-dev-schlafdata-cloud.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-k8s-dev-schlafdata-cloud-ingress-udp-1to65535-masters-k8s-dev-schlafdata-cloud" {
  from_port                = 1
  protocol                 = "udp"
  security_group_id        = aws_security_group.masters-k8s-dev-schlafdata-cloud.id
  source_security_group_id = aws_security_group.nodes-k8s-dev-schlafdata-cloud.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "https-elb-to-master" {
  cidr_blocks       = ["174.64.0.0/16"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.masters-k8s-dev-schlafdata-cloud.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "icmp-pmtu-api-elb-10-8-0-0--24" {
  cidr_blocks       = ["10.8.0.0/24"]
  from_port         = 3
  protocol          = "icmp"
  security_group_id = aws_security_group.masters-k8s-dev-schlafdata-cloud.id
  to_port           = 4
  type              = "ingress"
}

resource "aws_sqs_queue" "k8s-dev-schlafdata-cloud-nth" {
  message_retention_seconds = 300
  name                      = "k8s-dev-schlafdata-cloud-nth"
  policy                    = file("${path.module}/data/aws_sqs_queue_k8s-dev-schlafdata-cloud-nth_policy")
  tags = {
    "KubernetesCluster"                              = "k8s-dev.schlafdata.cloud"
    "Name"                                           = "k8s-dev-schlafdata-cloud-nth"
    "kubernetes.io/cluster/k8s-dev.schlafdata.cloud" = "owned"
  }
}

data "aws_vpc" "k8s-dev-schlafdata-cloud" {
  id = "vpc-0b5087f6bdafd0497"
}

terraform {
  required_version = ">= 0.15.0"
  required_providers {
    aws = {
      "configuration_aliases" = [aws.files]
      "source"                = "hashicorp/aws"
      "version"               = ">= 4.0.0"
    }
  }
}

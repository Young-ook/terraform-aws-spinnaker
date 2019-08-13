## managed kubernetes master cluster

resource "aws_iam_role" "eks" {
  name               = local.eks-name
  assume_role_policy = data.aws_iam_policy_document.eks-trustrel.json
}

data "aws_iam_policy_document" "eks-trustrel" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "eks.amazonaws.com",
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

# security/policy
resource "aws_iam_role_policy_attachment" "eks-cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.id
}

resource "aws_iam_role_policy_attachment" "eks-service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks.id
}

# security/firewall
resource "aws_security_group" "eks" {
  name        = local.eks-name
  description = format("security group for eks node of %s", local.cluster-name)
  vpc_id      = aws_vpc.vpc.id

  tags = merge(
    local.eks-name-tag,
    local.vpc-k8s-shared-tag,
  )
}

resource "aws_security_group_rule" "eks-ingress-allow-node-pool" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  description              = "https traffic from node pool"
  source_security_group_id = aws_security_group.nodes.id
  security_group_id        = aws_security_group.eks.id
}

resource "aws_security_group_rule" "eks-egress-allow-node-pool" {
  type                     = "egress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  description              = "tcp traffics to node pool"
  source_security_group_id = aws_security_group.nodes.id
  security_group_id        = aws_security_group.eks.id
}

# eks cluster
resource "aws_eks_cluster" "eks" {
  name     = local.cluster-name
  role_arn = aws_iam_role.eks.arn
  version  = var.kube_version

  vpc_config {
    subnet_ids         = aws_subnet.private.*.id
    security_group_ids = [aws_security_group.eks.id]
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster,
    aws_iam_role_policy_attachment.eks-service,
    aws_subnet.private,
  ]
}

# kube config
data "template_file" "kube-config" {
  template = file(format("%s/res/kube-config.tpl", path.module))

  vars = {
    cluster_name       = local.cluster-name
    cluster_arn        = aws_eks_cluster.eks.arn
    node_pool_role_arn = aws_iam_role.nodes.arn
    aws_region         = var.region
    aws_profile        = var.aws_profile
  }
}

resource "local_file" "update-kubeconfig" {
  content  = data.template_file.kube-config.rendered
  filename = format("%s/%s/update-kubeconfig.sh", path.cwd, local.cluster-name)
}

data "template_file" "kube-svc" {
  template = file(format("%s/res/kube-svc.tpl", path.module))

  vars = {
    cluster_name   = local.cluster-name
    elb_sec_policy = var.elb_sec_policy
    ssl_cert_arn   = var.ssl_cert_arn
  }
}

resource "local_file" "create-svc-lb" {
  content  = data.template_file.kube-svc.rendered
  filename = format("%s/%s/create-kubelb.sh", path.cwd, local.cluster-name)
}

## auto scaling group for node-pool of kubernetes

# container optimized ami
data "aws_ami" "eks-linux-ami" {
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.kube_version}-*"]
  }
}

# security/policy
resource "aws_iam_role" "nodes" {
  name               = local.nodes-name
  assume_role_policy = data.aws_iam_policy_document.nodes-trustrel.json
}

data "aws_iam_policy_document" "nodes-trustrel" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "eks-nodes" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "eks-cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "eks-ecr-read" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_instance_profile" "nodes" {
  name = local.nodes-name
  role = aws_iam_role.nodes.name
}

# security/firewall
resource "aws_security_group" "nodes" {
  name        = local.nodes-name
  description = format("security group for worker node of %s", local.cluster-name)
  vpc_id      = aws_vpc.vpc.id

  tags = merge(
    local.nodes-name-tag,
    local.vpc-k8s-shared-tag,
  )
}

resource "aws_security_group_rule" "nodes-ingress-allow-master-https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  description              = "https traffic from master cluster"
  source_security_group_id = aws_security_group.eks.id
  security_group_id        = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "nodes-ingress-allow-master-tcp" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  description              = "https traffic from master cluster"
  source_security_group_id = aws_security_group.eks.id
  security_group_id        = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "nodes-ingress-allow-each-other" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  description              = "all traffics from other nodes"
  source_security_group_id = aws_security_group.nodes.id
  security_group_id        = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "nodes-egress-allow-all" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "all outbound traffics"
  security_group_id = aws_security_group.nodes.id
}

# bootstrap
data "template_file" "nodes-userdata" {
  template = file("${path.module}/res/nodes.tpl")

  vars = {
    name      = local.cluster-name
    endpoint  = aws_eks_cluster.eks.endpoint
    cert_auth = aws_eks_cluster.eks.certificate_authority[0].data
  }
}

# launch configuration
resource "aws_launch_configuration" "nodes" {
  image_id             = var.kube_node_ami == "" ? data.aws_ami.eks-linux-ami.id : var.kube_node_ami
  instance_type        = var.kube_node_type
  name_prefix          = "${local.nodes-name}-"
  security_groups      = [aws_security_group.nodes.id]
  iam_instance_profile = aws_iam_instance_profile.nodes.name
  user_data            = data.template_file.nodes-userdata.rendered

  root_block_device {
    volume_type = var.kube_node_vol_type
    volume_size = var.kube_node_vol_size
  }

  lifecycle {
    create_before_destroy = true
  }
}

# auto scaling group
resource "aws_autoscaling_group" "nodes" {
  name                 = local.nodes-name
  max_size             = var.kube_node_size
  min_size             = var.kube_node_size
  desired_capacity     = var.kube_node_size
  vpc_zone_identifier  = aws_subnet.private.*.id
  availability_zones   = var.azs
  launch_configuration = aws_launch_configuration.nodes.name
  termination_policies = ["Default"]
  force_delete         = true

  lifecycle {
    create_before_destroy = true
  }

  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = local.nodes-name
        "propagate_at_launch" = "true"
      },
      local.vpc-k8s-owned-tag,
    ],
  )

  depends_on = [aws_subnet.private]
}

# security/policy

###
# bake
###
data "aws_iam_policy_document" "rosco-bake" {
  statement {
    actions = [
      "iam:PassRole",
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CreateKeypair",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteKeyPair",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSnapshot",
      "ec2:DeleteVolume",
      "ec2:DeregisterImage",
      "ec2:DescribeImageAttribute",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
      "ec2:GetPasswordData",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifySnapshotAttribute",
      "ec2:RegisterImage",
      "ec2:RunInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances",
      "ec2:RequestSpotInstances",
      "ec2:CancelSpotInstanceRequests",
      "ec2:DescribeSpotInstanceRequests",
      "ec2:DescribeSpotPriceHistory",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "rosco-bake" {
  name   = "${local.name}-bake"
  policy = data.aws_iam_policy_document.rosco-bake.json
}

###
# describes ec2
###
data "aws_iam_policy_document" "spin-ec2read" {
  statement {
    actions = [
      "ec2:Describe*",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "spin-ec2read" {
  name   = "${local.name}-ec2read"
  policy = data.aws_iam_policy_document.spin-ec2read.json
}

###
# assume to cross account spinnaker-managed role
###
data "aws_iam_policy_document" "spin-assume" {
  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    resources = var.assume_role_arn
  }
}

resource "aws_iam_policy" "spin-assume" {
  name   = "${local.name}-assume"
  policy = data.aws_iam_policy_document.spin-assume.json
}


### policy attachment to allow pods to access aws resources

resource "aws_iam_role_policy_attachment" "spin-s3admin" {
  policy_arn = aws_iam_policy.s3admin.arn
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "spin-bake" {
  policy_arn = aws_iam_policy.rosco-bake.arn
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "spin-ec2read" {
  policy_arn = aws_iam_policy.spin-ec2read.arn
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "spin-assume" {
  policy_arn = aws_iam_policy.spin-assume.arn
  role       = aws_iam_role.nodes.name
}

# security/firewall
resource "aws_security_group" "rosco-bake" {
  name        = "${local.nodes-name}-bake"
  description = "security group for image baker of ${local.cluster-name}"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "${local.nodes-name}-bake"
    },
    local.vpc-k8s-shared-tag,
  )
}

resource "aws_security_group_rule" "rosco-bake-ingress-allow-ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  description              = "ssh traffic from packer in rosco"
  source_security_group_id = aws_security_group.nodes.id
  security_group_id        = aws_security_group.rosco-bake.id
}

resource "aws_security_group_rule" "rosco-bake-egress-allow-all" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "all outbound traffics"
  security_group_id = aws_security_group.rosco-bake.id
}


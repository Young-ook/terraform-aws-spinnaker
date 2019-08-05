# auto scaling group for nodes

# container optimized ami
data "aws_ami" "eks-linux-ami" {
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.kube_version}-*"]
  }
}

### kuberetes nodes
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
  description = "security group for worker node of ${local.cluster-name}"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = local.nodes-name
    },
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

### policy attachment to allow pods in node access aws resources

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


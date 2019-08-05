# ecs for kubernetes

# kubernetes eks
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

# eks cluster policy/role 
resource "aws_iam_role_policy_attachment" "eks-cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.id
}

# eks service policy/role 
resource "aws_iam_role_policy_attachment" "eks-service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks.id
}

# security/firewall
resource "aws_security_group" "eks" {
  name        = local.eks-name
  description = "security group for eks node of ${local.cluster-name}"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = local.eks-name
    },
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
  template = file("${path.module}/res/kube-config.tpl")

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
  filename = "${path.cwd}/${local.cluster-name}/update-kubeconfig.sh"
}

data "template_file" "kube-svc" {
  template = file("${path.module}/res/kube-svc.tpl")

  vars = {
    cluster_name   = local.cluster-name
    elb_sec_policy = var.elb_sec_policy
    ssl_cert_arn   = var.ssl_cert_arn
  }
}

resource "local_file" "create-svc-lb" {
  content  = data.template_file.kube-svc.rendered
  filename = "${path.cwd}/${local.cluster-name}/create-kubelb.sh"
}

## managed kubernetes master cluster

# security/policy
resource "aws_iam_role" "eks" {
  name = format("%s-eks", local.name)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-cluster" {
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSClusterPolicy", data.aws_partition.current.partition)
  role       = aws_iam_role.eks.id
}

resource "aws_iam_role_policy_attachment" "eks-service" {
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSServicePolicy", data.aws_partition.current.partition)
  role       = aws_iam_role.eks.id
}

# eks cluster
resource "aws_eks_cluster" "eks" {
  name     = format("%s", local.name)
  role_arn = aws_iam_role.eks.arn
  version  = var.kube_version
  tags     = merge(local.name-tag, var.tags)

  vpc_config {
    subnet_ids = aws_subnet.private.*.id
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster,
    aws_iam_role_policy_attachment.eks-service,
    aws_subnet.private,
  ]
}

# security/policy
resource "aws_iam_role" "ng" {
  name = format("%s", local.name)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "ng-eks" {
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSWorkerNodePolicy", data.aws_partition.current.partition)
  role       = aws_iam_role.ng.name
}

resource "aws_iam_role_policy_attachment" "ng-cni" {
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKS_CNI_Policy", data.aws_partition.current.partition)
  role       = aws_iam_role.ng.name
}

resource "aws_iam_role_policy_attachment" "ng-ecr-read" {
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", data.aws_partition.current.partition)
  role       = aws_iam_role.ng.name
}

# eks node group
resource "aws_eks_node_group" "ng" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = aws_eks_cluster.eks.name
  node_role_arn   = aws_iam_role.ng.arn
  subnet_ids      = aws_subnet.private.*.id
  disk_size       = var.kube_node_vol_size
  instance_types  = [var.kube_node_type]
  version         = aws_eks_cluster.eks.version
  tags            = merge(local.name-tag, var.tags)

  scaling_config {
    max_size     = var.kube_node_size
    min_size     = var.kube_node_size
    desired_size = var.kube_node_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.ng-eks,
    aws_iam_role_policy_attachment.ng-cni,
    aws_iam_role_policy_attachment.ng-ecr-read,
  ]
}

# security/policy
# bake
resource "aws_iam_policy" "rosco-bake" {
  name = format("%s-bake", local.name)
  policy = jsonencode({
    Statement = [{
      Action = [
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
      Effect   = "Allow"
      Resource = ["*"]
    }]
    Version = "2012-10-17"
  })
}

# describes ec2
resource "aws_iam_policy" "spin-ec2read" {
  name = format("%s-ec2read", local.name)
  policy = jsonencode({
    Statement = [{
      Action   = "ec2:Describe*"
      Effect   = "Allow"
      Resource = ["*"]
    }]
    Version = "2012-10-17"
  })
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
  name   = format("%s-assume", local.name)
  policy = data.aws_iam_policy_document.spin-assume.json
}


### policy attachment to allow pods to access aws resources

resource "aws_iam_role_policy_attachment" "spin-s3admin" {
  policy_arn = aws_iam_policy.spin-s3admin.arn
  role       = aws_iam_role.ng.name
}

resource "aws_iam_role_policy_attachment" "spin-bake" {
  policy_arn = aws_iam_policy.rosco-bake.arn
  role       = aws_iam_role.ng.name
}

resource "aws_iam_role_policy_attachment" "spin-ec2read" {
  policy_arn = aws_iam_policy.spin-ec2read.arn
  role       = aws_iam_role.ng.name
}

resource "aws_iam_role_policy_attachment" "spin-assume" {
  policy_arn = aws_iam_policy.spin-assume.arn
  role       = aws_iam_role.ng.name
}

data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

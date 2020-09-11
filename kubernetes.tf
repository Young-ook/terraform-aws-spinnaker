
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
resource "aws_iam_policy" "spin-assume" {
  name = format("%s-assume", local.name)
  policy = jsonencode({
    Statement = [{
      Action   = "sts:AssumeRole"
      Effect   = "Allow"
      Resource = var.assume_role_arn
    }]
    Version = "2012-10-17"
  })
}


### policy attachment to allow pods to access aws resources

resource "aws_iam_role_policy_attachment" "spin-s3admin" {
  policy_arn = aws_iam_policy.spin-s3admin.arn
  role       = module.eks.role.name
}

resource "aws_iam_role_policy_attachment" "spin-bake" {
  policy_arn = aws_iam_policy.rosco-bake.arn
  role       = module.eks.role.name
}

resource "aws_iam_role_policy_attachment" "spin-ec2read" {
  policy_arn = aws_iam_policy.spin-ec2read.arn
  role       = module.eks.role.name
}

resource "aws_iam_role_policy_attachment" "spin-assume" {
  policy_arn = aws_iam_policy.spin-assume.arn
  role       = module.eks.role.name
}

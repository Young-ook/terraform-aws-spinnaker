# iam.tf
# identity and access management

### bake 
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
  policy = "${data.aws_iam_policy_document.rosco-bake.json}"
}

### describes ec2
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
  policy = "${data.aws_iam_policy_document.spin-ec2read.json}"
}

### assume role
data "aws_iam_policy_document" "spin-assume" {
  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    resources = ["${var.assume_role_arn}"]
  }
}

resource "aws_iam_policy" "spin-assume" {
  name   = "${local.name}-assume"
  policy = "${data.aws_iam_policy_document.spin-assume.json}"
}

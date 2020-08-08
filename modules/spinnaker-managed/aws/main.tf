# spinnaker managed
resource "aws_iam_role" "spinnaker-managed" {
  name = local.name
  path = "/"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [
          format("ecs.%s", data.aws_partition.current.dns_suffix),
          format("ecs-tasks.%s", data.aws_partition.current.dns_suffix),
          format("application-autoscaling.%s", data.aws_partition.current.dns_suffix)
        ],
        AWS = var.trusted_role_arn
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "vpc-full-accs" {
  policy_arn = format("arn:%s:iam::aws:policy/AmazonVPCFullAccess", data.aws_partition.current.partition)
  role       = aws_iam_role.spinnaker-managed.id
}

resource "aws_iam_role_policy_attachment" "ec2-full-accs" {
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEC2FullAccess", data.aws_partition.current.partition)
  role       = aws_iam_role.spinnaker-managed.id
}

resource "aws_iam_role_policy_attachment" "ecs-full-accs" {
  policy_arn = format("arn:%s:iam::aws:policy/AmazonECS_FullAccess", data.aws_partition.current.partition)
  role       = aws_iam_role.spinnaker-managed.id
}

resource "aws_iam_role_policy_attachment" "ecs-task-exec" {
  policy_arn = format("arn:%s:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy", data.aws_partition.current.partition)
  role       = aws_iam_role.spinnaker-managed.id
}

resource "aws_iam_role_policy_attachment" "secret-manager" {
  policy_arn = format("arn:%s:iam::aws:policy/SecretsManagerReadWrite", data.aws_partition.current.partition)
  role       = aws_iam_role.spinnaker-managed.id
}

resource "aws_iam_role_policy_attachment" "lambda-full-accs" {
  policy_arn = format("arn:%s:iam::aws:policy/AWSLambdaFullAccess", data.aws_partition.current.partition)
  role       = aws_iam_role.spinnaker-managed.id
}

resource "aws_iam_role_policy_attachment" "ecr-read" {
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", data.aws_partition.current.partition)
  role       = aws_iam_role.spinnaker-managed.id
}

resource "aws_iam_role_policy_attachment" "cfn-full-accs" {
  policy_arn = format("arn:%s:iam::aws:policy/AWSCloudFormationFullAccess", data.aws_partition.current.partition)
  role       = aws_iam_role.spinnaker-managed.id
}

resource "aws_iam_role_policy_attachment" "iam-read" {
  policy_arn = format("arn:%s:iam::aws:policy/IAMReadOnlyAccess", data.aws_partition.current.partition)
  role       = aws_iam_role.spinnaker-managed.id
}

# base iam intance-profile
resource "aws_iam_role" "base-iam" {
  name = "BaseIAMRole"
  path = "/"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [
          format("ec2.%s", data.aws_partition.current.dns_suffix),
          format("ecs-tasks.%s", data.aws_partition.current.dns_suffix)
        ]
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_instance_profile" "base-iam" {
  name = "BaseIAMRole"
  role = aws_iam_role.base-iam.name
}

resource "aws_iam_role" "iam-ecs-task-role" {
  name = "${var.account}-iam-${var.env}-${var.system}-ecs-iam-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
  tags = {
    Name        = "${var.account}-iam-${var.env}-${var.system}-ecs-iam-role",
    Environment = var.env,
    System      = var.name,
  }
}

resource "aws_iam_role_policy" "task-execution-role-policy" {
  name = "${var.account}-iam-policy-${var.env}-${var.system}-ecs-task-definition"
  role = aws_iam_role.iam-ecs-task-role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "lambda:InvokeFunction",
          "sqs:ReceiveMessage",
          "kafka:*",
          "secretsmanager:GetSecretValue",
          "rds:Describe*",
          "rds-data:ExecuteStatement",
          "rds-db:connect"

        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

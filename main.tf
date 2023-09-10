# Create an AWS Secrets Manager secret
resource "aws_secretsmanager_secret" "Auroro-secret" {
  name = "auroro-db-secret"
   rotation_rules {
    automatically_after_days = 30
  }
}

/*resource "aws_secretsmanager_secret_version" "Auroro-secret-version" {
  secret_id     = aws_secretsmanager_secret.Auroro-secret.id
  secret_string = "dbuserpassword"
}*/

variable "secretkey" {
  default = {
    username = "dbadminuser"
    password = "password4"
  }

  type = map(string)
}

resource "aws_secretsmanager_secret_version" "Auroro-secret-version" {
  secret_id     = aws_secretsmanager_secret.Auroro-secret.id
  secret_string = jsonencode(var.secretkey)
}


#lamda role
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  managed_policy_arns = [ "arn:aws:iam::aws:policy/AWSResourceAccessManagerFullAccess" ]
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = ["lambda.amazonaws.com","secretsmanager.amazonaws.com"]
        }
      }
    ]
  })
}


# IAM policy for logging from a lambda

resource "aws_iam_policy" "iam_policy_for_lambda" {

  name         = "aws_iam_policy_for_terraform_aws_lambda_role"
  path         = "/"
  description  = "AWS IAM Policy for managing aws lambda role"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "secrectmanager:GetSecrectValue"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Policy Attachment on the role.

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role        = aws_iam_role.lambda_execution_role.name
  policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

data "archive_file" "zip_the_python_code" {
 type        = "zip"
 source_dir  = "${path.module}/python/"
 output_path = "${path.module}/python/lamda-python.zip"
}

#create lamda function

resource "aws_lambda_function" "secret_rotation_lambda" {
  filename      = "${path.module}/python/lamda-python.zip" # Path to your Lambda code
  function_name = "secret_rotation_lambda"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lamda.lambda_handler"   #lamda python filename.lamdafunction name
  runtime       = "python3.8"    # Change to match your Lambda runtime
  depends_on    = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]

  # You need to provide the appropriate environment variables and other configuration for your Lambda function.
  # Environment variables could include the secret name and rotation logic configuration.
  environment {
    variables = {
      SecretId = aws_secretsmanager_secret.Auroro-secret.arn
    }
  }
}

/*
#sceret rotation -- Fix lamda function
resource "aws_secretsmanager_secret_rotation" "Auroro-secret-rotation" {
  secret_id           = aws_secretsmanager_secret.Auroro-secret.id
  rotation_lambda_arn = aws_lambda_function.secret_rotation_lambda.arn

  rotation_rules {
    automatically_after_days = 30
  }
}
*/
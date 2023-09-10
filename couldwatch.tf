# Create a CloudWatch Events rule to trigger the Lambda when the secret is viewed
resource "aws_cloudwatch_event_rule" "secret_view_event" {
  name = "secret_view_event"

  # Define the event pattern to match "GetSecretValue" API calls for your secret
  event_pattern = jsonencode({
    source = ["aws.secretsmanager"],
    detail = {
      eventSource = ["secretsmanager.amazonaws.com"],
      eventName   = ["GetSecretValue"]
    },
    resources = [aws_secretsmanager_secret.Auroro-secret.arn],
  })
}

# Create a target for the CloudWatch Events rule to invoke the Lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.secret_view_event.name
  target_id = "invoke_lambda"

  arn = aws_lambda_function.secret_rotation_lambda.arn
}

# Grant permission to CloudWatch Events to invoke the Lambda function
resource "aws_lambda_permission" "event_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.secret_rotation_lambda.function_name
  principal     = "events.amazonaws.com"

  source_arn = aws_cloudwatch_event_rule.secret_view_event.arn
}

# Optionally, create a CloudWatch Events schedule rule for periodic rotation
# This is only needed if you want to automate secret rotation on a schedule.
resource "aws_cloudwatch_event_rule" "rotation_schedule" {
  name = "rotation_schedule"
  
  # Define the schedule for secret rotation (e.g., daily, weekly, etc.)
  schedule_expression = "rate(1 day)"
}

# Associate the rotation schedule rule with the Lambda function
resource "aws_cloudwatch_event_target" "rotation_schedule_target" {
  rule      = aws_cloudwatch_event_rule.rotation_schedule.name
  target_id = "invoke_lambda_rotation"

  arn = aws_lambda_function.secret_rotation_lambda.arn
}

# Grant permission to CloudWatch Events to invoke the Lambda function for rotation
resource "aws_lambda_permission" "event_permission_rotation" {
  statement_id  = "AllowExecutionFromCloudWatchRotation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.secret_rotation_lambda.function_name
  principal     = "events.amazonaws.com"

  source_arn = aws_cloudwatch_event_rule.rotation_schedule.arn
}
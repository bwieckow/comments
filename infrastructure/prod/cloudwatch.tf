resource "aws_cloudwatch_log_group" "comments" {
  provider = aws.virginia

  name              = "/aws/lambda/${aws_lambda_function.comments.function_name}"
  retention_in_days = 30
}

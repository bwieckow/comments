resource "aws_lambda_function" "comments" {
  provider = aws.virginia

  function_name = "comments"
  role          = aws_iam_role.comments.arn
  handler       = "comment.lambda_handler" # Updated handler
  runtime       = "python3.13"             # Latest Python version supported by AWS Lambda

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout = 15
}

resource "aws_lambda_function_url" "comments" {
  provider = aws.virginia

  function_name      = aws_lambda_function.comments.function_name
  authorization_type = "AWS_IAM"
  cors {
    allow_origins = ["http://localhost:3000", "http://opsmaster.s3-website-eu-west-1.amazonaws.com", "https://www.ops-master.com", "https://ops-master.com"]
    allow_methods = ["GET", "POST"]
    allow_headers = ["*"]
  }
}

resource "aws_lambda_permission" "cloudfront_origin_access_control" {
  provider = aws.virginia

  statement_id  = "AllowCloudFrontServicePrincipal"
  action        = "lambda:InvokeFunctionUrl"
  function_name = aws_lambda_function.comments.function_name
  principal     = "cloudfront.amazonaws.com"
  source_arn    = data.aws_cloudfront_distribution.opsmaster.arn
}

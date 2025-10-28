resource "aws_lambda_function" "comments" {
  provider = aws.virginia

  function_name = "comments-dev"
  role          = aws_iam_role.comments.arn
  handler       = "comment.lambda_handler" # Updated handler
  runtime       = "python3.13"             # Latest Python version supported by AWS Lambda

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout = 15

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.comments.name
    }
  }
}

resource "aws_lambda_function_url" "comments" {
  provider = aws.virginia

  function_name      = aws_lambda_function.comments.function_name
  authorization_type = "NONE"
  cors {
    allow_origins = ["http://localhost:3000", "https://dev.ops-master.com"]
    allow_methods = ["GET", "POST"]
    allow_headers = ["*"]
  }
}

# resource "aws_lambda_permission" "cloudfront_origin_access_control" {
#   provider = aws.virginia

#   statement_id  = "AllowCloudFrontServicePrincipal"
#   action        = "lambda:InvokeFunctionUrl"
#   function_name = aws_lambda_function.comments.function_name
#   principal     = "cloudfront.amazonaws.com"
#   source_arn    = data.aws_cloudfront_distribution.opsmaster.arn
# }

resource "aws_lambda_function" "comments" {
  function_name = "comments"
  role          = aws_iam_role.comments.arn
  handler       = "comment.lambda_handler"  # Updated handler
  runtime       = "python3.13" # Latest Python version supported by AWS Lambda

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout = 15
}

resource "aws_lambda_function_url" "comments" {
  function_name      = aws_lambda_function.comments.function_name
  authorization_type = "NONE"
  cors {
    allow_origins = ["http://localhost:3000", "http://opsmaster.s3-website-eu-west-1.amazonaws.com"]
    allow_methods = ["GET", "POST"]
    allow_headers = ["*"]
  }
}

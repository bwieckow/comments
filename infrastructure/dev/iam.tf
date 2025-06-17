resource "aws_iam_role" "comments" {
  name = "comments-dev"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "comments" {
  name = "comments-dev"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan" # Added Scan action
        ],
        Resource = aws_dynamodb_table.comments.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "comments" {
  role       = aws_iam_role.comments.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "comments_api_policy" {
  role       = aws_iam_role.comments.name
  policy_arn = aws_iam_policy.comments.arn
}

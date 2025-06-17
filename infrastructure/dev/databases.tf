resource "aws_dynamodb_table" "comments" {
  name           = "comments-dev"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }
}

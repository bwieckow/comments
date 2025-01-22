resource "aws_dynamodb_table" "comments" {
  name           = "comments"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "comment_id"
  range_key      = "user_id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "db-table" {
  name     = "Nandan"
  hash_key = "RideId"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "RideId"
    type = "S"
  }

  tags = {
    Owner = "Nandan"
  }
}

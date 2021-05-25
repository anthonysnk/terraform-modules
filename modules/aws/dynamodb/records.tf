resource "aws_dynamodb_table_item" "default" {
  count      = var.items_file != "" && var.enable_global_table == 0 ? 1 : 0
  table_name = aws_dynamodb_table.default.name
  hash_key   = aws_dynamodb_table.default.hash_key

  item = file(var.items_file)
}

resource "aws_dynamodb_table_item" "default_global" {
  count      = var.items_file != "" && var.enable_global_table == 1 ? 1 : 0
  table_name = aws_dynamodb_global_table.default[0].name
  hash_key   = aws_dynamodb_table.default.hash_key

  item = file(var.items_file)
}


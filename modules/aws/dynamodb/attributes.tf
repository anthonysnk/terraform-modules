# https://www.dynamodbguide.com/secondary-indexes/
# https://www.terraform.io/docs/providers/aws/r/dynamodb_table.html
resource "null_resource" "local_secondary_index_names" {
  count = length(var.local_secondary_index_map)

  # https://www.terraform.io/docs/providers/aws/r/dynamodb_table.html#non_key_attributes-1
  triggers = {
    "name" = var.local_secondary_index_map[count.index]["name"]
  }
}

# https://www.dynamodbguide.com/secondary-indexes/
# https://www.terraform.io/docs/providers/aws/r/dynamodb_table.html
resource "null_resource" "global_secondary_index_names" {
  count = length(var.global_secondary_index_map)

  # https://www.terraform.io/docs/providers/aws/r/dynamodb_table.html#non_key_attributes-1
  triggers = {
    "name" = var.global_secondary_index_map[count.index]["name"]
  }
}


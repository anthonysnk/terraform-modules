# --------------------------------------------------------------------
# DynamoDB Table
# --------------------------------------------------------------------

resource "aws_dynamodb_table" "default" {
  name = var.table_name

  # Billing and capacity
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.base_read_capacity : 0
  write_capacity = var.billing_mode == "PROVISIONED" ? var.base_write_capacity : 0

  # Attributes
  hash_key  = var.hash_key
  range_key = var.range_key

  dynamic "attribute" {
    for_each = local.attributes_list
    content {
      name = attribute.value["name"]
      type = attribute.value["type"]
    }
  }

  dynamic "local_secondary_index" {
    for_each = var.local_secondary_index_map
    content {
      name               = local_secondary_index.value.name
      non_key_attributes = lookup(local_secondary_index.value, "non_key_attributes", null)
      projection_type    = local_secondary_index.value.projection_type
      range_key          = local_secondary_index.value.range_key
    }
  }
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_index_map
    content {

      hash_key           = global_secondary_index.value.hash_key
      name               = global_secondary_index.value.name
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
      projection_type    = global_secondary_index.value.projection_type
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      read_capacity      = lookup(global_secondary_index.value, "read_capacity", null)
      write_capacity     = lookup(global_secondary_index.value, "write_capacity", null)
    }
  }

  # Configuration
  stream_enabled   = var.enable_streams
  stream_view_type = var.enable_streams ? var.stream_view_type : ""

  server_side_encryption {
    enabled = var.enable_encryption
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  ttl {
    attribute_name = var.ttl_attribute_name
    enabled        = var.enable_ttl
  }

  lifecycle {
    ignore_changes = [
      read_capacity,
      write_capacity,
    ]
  }

  tags = var.tags
}

resource "aws_dynamodb_table" "default-replica" {
  provider = aws.secondary_region
  count    = var.enable_global_table ? 1 : 0
  name     = var.table_name

  # Billing and capacity
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.base_read_capacity : 0
  write_capacity = var.billing_mode == "PROVISIONED" ? var.base_write_capacity : 0

  # Attributes
  hash_key  = var.hash_key
  range_key = var.range_key

  dynamic "attribute" {
    for_each = local.attributes_list
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }
  dynamic "local_secondary_index" {
    for_each = var.local_secondary_index_map
    content {
      name               = local_secondary_index.value.name
      non_key_attributes = lookup(local_secondary_index.value, "non_key_attributes", null)
      projection_type    = local_secondary_index.value.projection_type
      range_key          = local_secondary_index.value.range_key
    }
  }
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_index_map
    content {

      hash_key           = global_secondary_index.value.hash_key
      name               = global_secondary_index.value.name
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
      projection_type    = global_secondary_index.value.projection_type
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      read_capacity      = lookup(global_secondary_index.value, "read_capacity", null)
      write_capacity     = lookup(global_secondary_index.value, "write_capacity", null)
    }
  }

  # Configuration
  stream_enabled   = var.enable_streams
  stream_view_type = var.enable_streams == 1 ? var.stream_view_type : ""

  server_side_encryption {
    enabled = var.enable_encryption
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  ttl {
    attribute_name = var.ttl_attribute_name
    enabled        = var.enable_ttl
  }

  lifecycle {
    ignore_changes = [
      read_capacity,
      write_capacity,
    ]
  }

  tags = var.tags
}

resource "aws_dynamodb_global_table" "default" {
  count = var.enable_global_table == 1 ? 1 : 0

  depends_on = [
    aws_dynamodb_table.default,
    aws_dynamodb_table.default-replica,
  ]

  name = var.table_name

  replica {
    region_name = var.region
  }

  replica {
    region_name = var.secondary_region
  }
}


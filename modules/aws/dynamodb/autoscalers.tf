resource "aws_appautoscaling_target" "dynamodb_table_read_target" {
  depends_on         = [aws_dynamodb_table.default]
  count              = var.billing_mode == "PROVISIONED" ? 1 : 0
  min_capacity       = var.base_read_capacity
  max_capacity       = var.max_read_capacity
  resource_id        = "table/${aws_dynamodb_table.default.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_target" "dynamodb_table_write_target" {
  depends_on         = [aws_dynamodb_table.default]
  count              = var.billing_mode == "PROVISIONED" ? 1 : 0
  min_capacity       = var.base_write_capacity
  max_capacity       = var.max_write_capacity
  resource_id        = "table/${aws_dynamodb_table.default.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_table_read_policy" {
  depends_on         = [aws_dynamodb_table.default]
  count              = var.billing_mode == "PROVISIONED" ? 1 : 0
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_read_target[0].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_read_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_read_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_read_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = var.target_utilization_value
  }
}

resource "aws_appautoscaling_policy" "dynamodb_table_write_policy" {
  depends_on         = [aws_dynamodb_table.default]
  count              = var.billing_mode == "PROVISIONED" ? 1 : 0
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_write_target[0].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_write_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_write_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_write_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = var.target_utilization_value
  }
}


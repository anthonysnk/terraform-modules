output "local_table_default_name" {
  value       = aws_dynamodb_table.default.name
  description = "DynamoDB table name"
}

output "local_table_default_id" {
  value       = aws_dynamodb_table.default.id
  description = "DynamoDB table ID"
}

output "local_table_default_arn" {
  value       = aws_dynamodb_table.default.arn
  description = "DynamoDB table ARN"
}

output "local_table_default_replica_name" {
  value       = element(concat(aws_dynamodb_table.default-replica.*.name, [""]), 0)
  description = "DynamoDB table name"
}

output "local_table_default_replica_id" {
  value       = element(concat(aws_dynamodb_table.default-replica.*.id, [""]), 0)
  description = "DynamoDB table ID"
}

output "local_table_default_replica_arn" {
  value       = element(concat(aws_dynamodb_table.default-replica.*.arn, [""]), 0)
  description = "DynamoDB table ARN"
}

output "global_table_name" {
  value       = element(concat(aws_dynamodb_global_table.default.*.name, [""]), 0)
  description = "DynamoDB global table name"
}

output "global_table_id" {
  value       = element(concat(aws_dynamodb_global_table.default.*.id, [""]), 0)
  description = "DynamoDB global table id"
}

output "global_table_arn" {
  value       = element(concat(aws_dynamodb_global_table.default.*.arn, [""]), 0)
  description = "DynamoDB global table arn"
}


output "zone" {
  description = "The created Hosted Zone(s)."
  value       = aws_route53_zone.aws-zone
}

output "records" {
  description = "A list of all created records."
  value       = aws_route53_record.aws-record
}

output "delegation_set" {
  description = "The outputs of the created delegation set."
  value       = try(aws_route53_delegation_set.aws-delegation-set[0], null)
}

output "module_enabled" {
  description = "Whether the module is enabled"
  value       = var.module_enabled
}

output "arn" {
  description = "AWS S3 Bucket ARN"
  value       = aws_s3_bucket.this.arn
}

output "domain_name" {
  description = "AWS S3 Bucket Domain Names"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "hosted_zone_id" {
  description = "AWS S3 Bucket Hosted Zone ID"
  value       = aws_s3_bucket.this.hosted_zone_id
}

output "id" {
  description = "AWS S3 Bucket ID"
  value       = aws_s3_bucket.this.id
}

# This is identical to "ids" above, but is used in references to provide clarity on what we're pulling out, in our case the bucket name
output "name" {
  description = "AWS S3 Bucket Name"
  value       = aws_s3_bucket.this.id
}

output "website_endpoint" {
  description = "AWS S3 Bucket Website Endpoint"
  value       = aws_s3_bucket.this.website_endpoint
}

output "website_domain" {
  description = "AWS S3 Bucket Website Domain Name"
  value       = aws_s3_bucket.this.website_domain
}

output "region" {
  description = "AWS S3 Bucket Region"
  value       = aws_s3_bucket.this.region
}


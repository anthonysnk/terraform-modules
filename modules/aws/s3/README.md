
# AWS S3 Buckets Terraform module
===============================

Terraform module which creates S3 buckets on AWS.

Adapted from an existing module in the Terraform Registry: https://registry.terraform.io/modules/devops-workflow/s3-buckets/aws
Removed some of the dependencies to make it more directly usable without the tagging and module dependencies, and to support both
public and private buckets in the same module based upon a count-based conditional.

## Usage
-----

```hcl
module "s3_buckets" {
  source       = "./modules/s3"
  name         = local.static_bucket_name[terraform.workspace]
  environment  = terraform.workspace
  organization = var.organization
  tags         = { workspace = terraform.workspace }
  public       = true
  host_website = true
  s3_write_principal  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  index_document = "dne"
  error_document = "static/index.html"
  force_kms    = false
}


```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attributes | Suffix name with additional attributes (policy, role, etc.) | list | `<list>` | no |
| bucket\_kms\_key\_arn | Default bucket encryption to use, pass either AES256 or a KMS key arn | string | `""` | no |
| cloudfront | True if this Web S3 bucket will be the origin of a CloudFront Distribution | string | `"false"` | no |
| distribution\_oai | The Cloudfront Oirgin Access Identity (OAI) to grant it read access to S3 website hosting bucket | string | `""` | no |
| environment | Environment (ex: `dev`, `qa`, `stage`, `prod`). (Second or top level namespace. Depending on namespacing options) | string | n/a | yes |
| error\_document | Name of the main error page document for the s3 bucket doing web hosting. | string | `"error.html"` | no |
| files | List of files to upload to the bucket once provisioned. | list | `<list>` | no |
| find\_extension | Regex to find file extension, used to lookup keys in mimetype map | string | `"/.+(\\..*)$/"` | no |
| force\_destroy | Delete all objects in bucket on destroy | string | `"false"` | no |
| force\_kms | Force only objects uploaded with KMS encryption to be allowed. | string | `"false"` | no |
| host\_website |  | string | `"false"` | no |
| index\_document | Name of the main index document for the s3 bucket doing web hosting. | string | `"index.html"` | no |
| mfa\_delete | Require mfa for s3 bucket delete operations | string | `"false"` | no |
| mimetype | Map of extensions to MIME types | map | `<map>` | no |
| name | S3 bucket name | string | n/a | yes |
| organization | Organization name (Top level namespace) | string | `""` | no |
| public | Allow public read access to bucket | string | `"false"` | no |
| sse_algorithm | String cotaining the type of algorithm used for server side encryption | string | `"AES256"` | no |
| region | AWS Region to provision within | string | `"us-east-1"` | no |
| s3\_basedir | Path to use for the start of the s3 bucket object tree | string | `"./content/"` | no |
| s3\_write\_principal | principal to grant bucket write permissions to | string | `""` | no |
| lifecycle_rule | | List of maps containing configuration of object lifecycle management | A map of additional tags | map | `<map>` | no |
 | map | `<map>` | no |
| cors_rule | Map containing a rule of Cross-Origin Resource Sharing | map | `<map>` | no |
| logging | Map containing access bucket logging configuration | map | `<map>` | no |
| object_lock_configuration | Map containing S3 object locking configuration | map | `<map>` | no |
| replication_configuration | Map containing cross-region replication configuration | map | `<map>` | no |
| tags | A map of additional tags | map | `<map>` | no |
| versioned | Enable versioning on the bucket | string | `"false"` | no |
| allow_encrypted_uploads_only | Blocks unencrypted objects to be written in the bucket | bool | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| arns | List of AWS S3 Bucket ARNs |
| domain\_names | List of AWS S3 Bucket Domain Names |
| hosted\_zone\_ids | List of AWS S3 Bucket Hosted Zone IDs |
| ids | List of AWS S3 Bucket IDs |
| names | List of AWS S3 Bucket Names |
| regions | List of AWS S3 Bucket Regions |
| website\_domains | List of AWS S3 Bucket Website Domain Names |
| website\_endpoints | List of AWS S3 Bucket Website Endpoints |

Applaudo Studios 2021
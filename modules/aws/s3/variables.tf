# Module variables

variable "attributes" {
  description = "Suffix name with additional attributes (policy, role, etc.)"
  type        = list(string)
  default     = []
}

variable "policy" {
  description = "(Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide."
  type        = string
  default     = null
}

variable "name" {
  description = "S3 bucket name"
  type        = string
}

variable "bucket_prefix" {
  description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "(Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "acceleration_status" {
  description = "(Optional) Sets the accelerate configuration of an existing bucket. Can be Enabled or Suspended."
  type        = string
  default     = null
}

variable "request_payer" {
  description = "(Optional) Specifies who should bear the cost of Amazon S3 data transfer. Can be either BucketOwner or Requester. By default, the owner of the S3 bucket would incur the costs of any data transfer. See Requester Pays Buckets developer guide for more information."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of additional tags"
  type        = map(string)
  default     = {}
}

variable "s3_write_principal" {
  description = "principal to grant bucket write permissions to"
  type        = string
  default     = ""
}

variable "acl" {
  description = "ACL applied to the bucket, accepted values: 'private' | 'public-read'"
  default     = "private"
}

variable "force_kms" {
  description = "Force only objects uploaded with KMS encryption to be allowed."
  default     = false
}

variable "versioned" {
  description = "Enable versioning on the bucket"
  default     = false
}

variable "mfa_delete" {
  description = "Require mfa for s3 bucket delete operations"
  default     = false
}

variable "host_website" {
  default = false
}

variable "website" {
  description = "Map containing static web-site hosting or redirect configuration."
  type        = map(string)
  default     = {}
}

variable "files" {
  description = "List of files to upload to the bucket once provisioned."
  default     = []
}

variable "region" {
  description = "AWS Region to provision within"
  default     = "us-east-1"
}

variable "s3_basedir" {
  description = "Path to use for the start of the s3 bucket object tree"
  default     = "./content/"
}

variable "find_extension" {
  description = "Regex to find file extension, used to lookup keys in mimetype map"
  default     = "/.+(\\..*)$/"
}

variable "bucket_kms_key_arn" {
  description = "Default bucket encryption to use, pass either AES256 or a KMS key arn"
  default     = ""
}

variable "cloudfront" {
  description = "True if this Web S3 bucket will be the origin of a CloudFront Distribution"
  default     = false
}

variable "distribution_oai" {
  description = "The Cloudfront Oirgin Access Identity (OAI) to grant it read access to S3 website hosting bucket"
  default     = ""
}

variable "use_acls" {
  description = "Enables or disables the use of ACLs"
  default     = false
}

variable "block_public_access" {
  description = "Blocks public access"
  default     = false
}

variable "allow_encrypted_uploads_only" {
  description = "Blocks unencrypted objects to be written in the bucket"
  default     = false
}

variable "cors_rule" {
  description = "Map containing a rule of Cross-Origin Resource Sharing."
  type        = any # should be `map`, but it produces an error "all map elements must have the same type" (Still on 0.15)
  default     = {}
}

variable "logging" {
  description = "Map containing access bucket logging configuration."
  type        = map(string)
  default     = {}
}

variable "lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}

variable "replication_configuration" {
  description = "Map containing cross-region replication configuration."
  type        = any
  default     = null
}

variable "sse_algorithm" {
  description = "String cotaining the type of algorithm used for server side encryption"
  default     = "AES256"
}

variable "object_lock_configuration" {
  description = "Map containing S3 object locking configuration."
  type        = any
  default     = {}
}


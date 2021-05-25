# --------------------------------------------------------------------
# General variables
# --------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to be added to the user."
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "The region to deploy the table"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "The region to deploy the table"
  type        = string
  default     = "us-west-1"
}

# --------------------------------------------------------------------
# DynamoDB Variables
# --------------------------------------------------------------------

variable "table_name" {
  description = "The name of the DynamoDB table"
  type        = string
  default     = "terraform_locks"
}

variable "hash_key" {
  description = "The hash key of the DynamoDB table"
  type        = string
  default     = "LockID"
}

variable "hash_key_type" {
  description = "The hash key type of the DynamoDB table"
  type        = string
  default     = "S"
}

variable "range_key" {
  description = "DynamoDB table Range Key"
  type        = string
  default     = ""
}

variable "range_key_type" {
  description = "Range Key type, which must be a scalar type: `S`, `N`, or `B` for (S)tring, (N)umber or (B)inary data"
  type        = string
  default     = "S"
}

variable "additional_attributes" {
  description = "Additional attributes as list of mapped values"
  type        = list(map(string))
  default     = []
}

variable "billing_mode" {
  description = "The billing mode for the DynamoDB table [PAY_PER_REQUEST|PROVISIONED]"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "base_read_capacity" {
  description = "The read capacity in provisioned mode for the DynamoDB table"
  type        = string
  default     = 5
}

variable "max_read_capacity" {
  description = "The max read capacity in provisioned mode for the DynamoDB table"
  type        = string
  default     = 50
}

variable "base_write_capacity" {
  description = "The write capacity in provisioned mode for the DynamoDB table"
  type        = string
  default     = 5
}

variable "max_write_capacity" {
  description = "The max write capacity in provisioned mode for the DynamoDB table"
  type        = string
  default     = 50
}

variable "target_utilization_value" {
  description = "The target utilization value before the autoscaler kicks in"
  type        = string
  default     = 75
}

variable "enable_streams" {
  description = "Enable streams, required for global tables"
  type        = string
  default     = true
}

variable "stream_view_type" {
  description = "Enable streams [KEYS_ONLY|NEW_IMAGE|OLD_IMAGE|NEW_AND_OLD_IMAGES], NEW_AND_OLD_IMAGES is required for global tables"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "enable_encryption" {
  description = "Enable encryption at rest"
  type        = string
  default     = true
}

variable "enable_point_in_time_recovery" {
  description = "Enable point in time recovery"
  type        = string
  default     = true
}

variable "enable_ttl" {
  description = "Enable TTL"
  type        = string
  default     = true
}

variable "enable_global_table" {
  description = "Enable global table"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "DynamoDB table TTL attribute name"
  type        = string
  default     = "Expires"
}

variable "global_secondary_index_map" {
  description = "Additional global secondary indexes in the form of a list of mapped values"
  type = list(object({
    name            = string
    hash_key        = string
    write_capacity  = number
    read_capacity   = number
    projection_type = string
  }))
  default = []
}

variable "local_secondary_index_map" {
  description = "Additional local secondary indexes in the form of a list of mapped values"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = list(string)
  }))
  default = []
}

variable "items_file" {
  description = "Sample records to insert at creation time"
  type        = string
  default     = ""
}


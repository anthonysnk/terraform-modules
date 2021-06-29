variable "name" {
  description = "(Required) The name of the hosted zone. To create multiple zones at once, pass a list of names [\"zone1\", \"zone2\"]."
  type        = any
  default     = null
}

variable "allow_overwrite" {
  description = "(Optional) Default allow_overwrite value valid for all record sets."
  type        = bool
  default     = false
}

variable "comment" {
  description = "(Optional) A comment for the hosted zone."
  type        = string
  default     = "Managed by Terraform"
}

variable "default_ttl" {
  description = "(Optional) The default TTL ( Time to Live ) in seconds that will be used for all records that support the ttl parameter. Will be overwritten by the records ttl parameter if set."
  type        = number
  default     = 3600
}

variable "delegation_set_id" {
  description = "(Optional) The ID of the reusable delegation set whose NS records you want to assign to the hosted zone."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "(Optional) Whether to force destroy all records (possibly managed outside of Terraform) in the zone when destroying the zone."
  type        = bool
  default     = false
}

variable "records" {
  description = "(Optional) A list of records to create in the Hosted Zone."
  type        = any
  default     = []
}

variable "reference_name" {
  description = "(Optional) The reference name used in Caller Reference (helpful for identifying single delegation set amongst others)."
  type        = string
  default     = null
}

variable "skip_delegation_set_creation" {
  description = "(Optional) Whether or not to create a delegation set and associate with the created zone."
  type        = bool
  default     = false
}

variable "tags" {
  description = "(Optional) A map of tags to apply to all created resources that support tags."
  type        = map(string)
  default     = {}
}

variable "vpc_ids" {
  description = "(Optional) A list of IDs of VPCs to associate with a private hosted zone. Conflicts with the delegation_set_id."
  type        = list(string)
  default     = []
}

variable "zone_id" {
  description = "(Optional) A zone ID to create the records in"
  type        = string
  default     = null
}

variable "module_enabled" {
  type        = bool
  description = "(Optional) Whether to create resources within the module or not. Default is true."
  default     = true
}

variable "module_depends_on" {
  type        = any
  description = "(Optional) A list of external resources the module depends_on. Default is []."
  default     = []
}

variable "skip_acm_certificate_creation" {
  type        = bool
  description = "(Optional) To create records with a ACM. Default is true"
  default     = true
}

variable "domain_name" {
  type        = string
  description = "(Opcional) If you dont want to create ACM"
  default     = null
}

variable "zone_id_acm" {
  type        = string
  description = "(Opcional) If you dont want to create ACM"
  default     = null
}
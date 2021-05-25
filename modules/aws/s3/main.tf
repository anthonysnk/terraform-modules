#-------------------------------
# AWS S3 Terraform module
#-------------------------------

resource "aws_s3_bucket" "this" {
  bucket              = var.name
  bucket_prefix       = var.bucket_prefix
  acl                 = var.acl
  policy              = var.policy
  force_destroy       = var.force_destroy
  acceleration_status = var.acceleration_status
  request_payer       = var.request_payer

  versioning {
    enabled    = var.versioned
    mfa_delete = var.mfa_delete
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.bucket_kms_key_arn == "" ? "AES256" : "aws:kms"
        kms_master_key_id = var.bucket_kms_key_arn == "" ? "" : var.bucket_kms_key_arn
      }
    }
  }

  dynamic "website" {
    for_each = length(keys(var.website)) == 0 ? [] : [var.website]

    content {
      index_document           = lookup(website.value, "index_document", null)
      error_document           = lookup(website.value, "error_document", null)
      redirect_all_requests_to = lookup(website.value, "redirect_all_requests_to", null)
      routing_rules            = lookup(website.value, "routing_rules", null)
    }
  }

  dynamic "cors_rule" {
    for_each = length(keys(var.cors_rule)) == 0 ? [] : [var.cors_rule]

    content {
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = lookup(cors_rule.value, "allowed_headers", null)
      expose_headers  = lookup(cors_rule.value, "expose_headers", null)
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", null)
    }
  }

  dynamic "logging" {
    for_each = length(keys(var.logging)) == 0 ? [] : [var.logging]

    content {
      target_bucket = logging.value.target_bucket
      target_prefix = lookup(logging.value, "target_prefix", null)
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rule

    content {
      id                                     = lookup(lifecycle_rule.value, "id", null)
      prefix                                 = lookup(lifecycle_rule.value, "prefix", null)
      tags                                   = lookup(lifecycle_rule.value, "tags", null)
      abort_incomplete_multipart_upload_days = lookup(lifecycle_rule.value, "abort_incomplete_multipart_upload_days", null)
      enabled                                = lifecycle_rule.value.enabled

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "expiration", {})]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = lookup(lifecycle_rule.value, "transition", [])

        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "noncurrent_version_expiration", {})]

        content {
          days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_transition", [])

        content {
          days          = lookup(noncurrent_version_transition.value, "days", null)
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }

  # Max 1 block - replication_configuration
  dynamic "replication_configuration" {
    for_each = var.replication_configuration != null ? length(keys(var.replication_configuration)) == 0 ? [] : [var.replication_configuration] : []

    content {
      role = replication_configuration.value.role

      dynamic "rules" {
        for_each = replication_configuration.value.rules

        content {
          id       = lookup(rules.value, "id", null)
          priority = lookup(rules.value, "priority", null)
          prefix   = lookup(rules.value, "prefix", null)
          status   = lookup(rules.value, "status", null)

          dynamic "destination" {
            for_each = length(keys(lookup(rules.value, "destination", {}))) == 0 ? [] : [lookup(rules.value, "destination", {})]

            content {
              bucket             = lookup(destination.value, "bucket", null)
              storage_class      = lookup(destination.value, "storage_class", null)
              replica_kms_key_id = lookup(destination.value, "replica_kms_key_id", null)
              account_id         = lookup(destination.value, "account_id", null)

              dynamic "access_control_translation" {
                for_each = length(keys(lookup(destination.value, "access_control_translation", {}))) == 0 ? [] : [lookup(destination.value, "access_control_translation", {})]

                content {
                  owner = access_control_translation.value.owner
                }
              }
            }
          }

          dynamic "source_selection_criteria" {
            for_each = length(keys(lookup(rules.value, "source_selection_criteria", {}))) == 0 ? [] : [lookup(rules.value, "source_selection_criteria", {})]

            content {

              dynamic "sse_kms_encrypted_objects" {
                for_each = length(keys(lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {}))) == 0 ? [] : [lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {})]

                content {

                  enabled = sse_kms_encrypted_objects.value.enabled
                }
              }
            }
          }

          dynamic "filter" {
            for_each = length(keys(lookup(rules.value, "filter", {}))) == 0 ? [] : [lookup(rules.value, "filter", {})]

            content {
              prefix = lookup(filter.value, "prefix", null)
              tags   = lookup(filter.value, "tags", null)
            }
          }

        }
      }
    }
  }

  # Max 1 block - object_lock_configuration
  dynamic "object_lock_configuration" {
    for_each = length(keys(var.object_lock_configuration)) == 0 ? [] : [var.object_lock_configuration]

    content {
      object_lock_enabled = object_lock_configuration.value.object_lock_enabled

      dynamic "rule" {
        for_each = length(keys(lookup(object_lock_configuration.value, "rule", {}))) == 0 ? [] : [lookup(object_lock_configuration.value, "rule", {})]

        content {
          default_retention {
            mode  = lookup(lookup(rule.value, "default_retention", {}), "mode")
            days  = lookup(lookup(rule.value, "default_retention", {}), "days", null)
            years = lookup(lookup(rule.value, "default_retention", {}), "years", null)
          }
        }
      }
    }
  }

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
  )
}

data "aws_caller_identity" "current" {
}

data "template_file" "policy_s3_priv" {
  count    = !var.host_website && !var.force_kms ? 1 : 0
  template = file("${path.module}/files/policy_s3_bucket.json")

  vars = {
    name      = aws_s3_bucket.this.id
    principal = var.s3_write_principal == "" ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" : var.s3_write_principal
  }
}

data "template_file" "policy_s3_priv_kms" {
  count    = !var.host_website && var.force_kms ? 1 : 0
  template = file("${path.module}/files/policy_s3_bucket_forcekms.json")

  vars = {
    name      = aws_s3_bucket.this.id
    principal = var.s3_write_principal == "" ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" : var.s3_write_principal
  }
}

resource "aws_s3_bucket_policy" "priv" {
  count  = var.use_acls && !var.host_website ? 1 : 0
  bucket = aws_s3_bucket.this.bucket
  policy = element(
    concat(
      data.template_file.policy_s3_priv.*.rendered,
      data.template_file.policy_s3_priv_kms.*.rendered,
    ),
    0,
  )
}

data "template_file" "policy_s3_web" {
  count    = var.host_website && !var.cloudfront && !var.force_kms ? 1 : 0
  template = file("${path.module}/files/policy_s3_bucket_public.json")

  vars = {
    name      = aws_s3_bucket.this.id
    principal = var.s3_write_principal == "" ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" : var.s3_write_principal
  }
}

data "template_file" "policy_s3_web_cloudfront" {
  count    = var.host_website && var.cloudfront && !var.force_kms ? 1 : 0
  template = file("${path.module}/files/policy_s3_bucket_cloudfront.json")

  vars = {
    name             = aws_s3_bucket.this.id
    distribution_oai = var.distribution_oai
    principal        = var.s3_write_principal == "" ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" : var.s3_write_principal
  }
}

data "template_file" "policy_s3_web_kms" {
  count    = var.host_website && !var.cloudfront && var.force_kms ? 1 : 0
  template = file("${path.module}/files/policy_s3_bucket_forcekms.json")

  vars = {
    name      = aws_s3_bucket.this.id
    principal = var.s3_write_principal == "" ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" : var.s3_write_principal
  }
}

data "template_file" "policy_s3_web_cloudfront_kms" {
  count = var.host_website && var.cloudfront && var.force_kms ? 1 : 0
  template = file(
    "${path.module}/files/policy_s3_bucket_cloudfront_forcekms.json",
  )

  vars = {
    name             = aws_s3_bucket.this.id
    distribution_oai = var.distribution_oai
    principal        = var.s3_write_principal == "" ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" : var.s3_write_principal
  }
}

resource "aws_s3_bucket_policy" "web" {
  count  = var.use_acls && var.host_website ? 1 : 0
  bucket = aws_s3_bucket.this.bucket
  policy = element(
    concat(
      data.template_file.policy_s3_web.*.rendered,
      data.template_file.policy_s3_web_cloudfront.*.rendered,
      data.template_file.policy_s3_web_kms.*.rendered,
      data.template_file.policy_s3_web_cloudfront_kms.*.rendered,
    ),
    0,
  )
}

resource "aws_s3_bucket_object" "priv" {
  count  = !var.host_website ? length(var.files) : 0
  bucket = aws_s3_bucket.this.bucket
  key    = element(var.files, count.index)
  source = element(var.files, count.index)
  etag   = filemd5(element(var.files, count.index))
}

resource "aws_s3_bucket_object" "web" {
  count  = var.host_website ? length(var.files) : 0
  bucket = aws_s3_bucket.this.bucket
  key = replace(
    element(var.files, count.index),
    local.s3_basedir_regex,
    "$1",
  )
  source = element(var.files, count.index)

  #
  # If we are making a web bucket, we need to provide content_type if we'd like the
  # uploaded objects to render as html, for example.  This var.mimetype is in a
  # standalone mimetype.tf file to avoid polluting variables.tf.  We then use the
  # replace interpolation to do a re2 regex of each filename in var.files, and then
  # parse out only the extension.  As each entry in the var.mimetype file is keyed on
  # .<extension> and returns the appropriate MIME type, we can pass this into the
  # content_type variable.  Lastly, if we somehow upload some extension not in that
  # map (say if you upload a filename with NO extension which will break the regex)
  # then default to application/octest-stream as the content_type.
  #
  content_type = lookup(
    var.mimetype,
    replace(element(var.files, count.index), var.find_extension, "$1"),
    "application/octet-stream",
  )

  etag = filemd5(element(var.files, count.index))
}

resource "aws_s3_bucket_public_access_block" "web" {
  count  = var.block_public_access && var.host_website ? 1 : 0
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

resource "aws_s3_bucket_public_access_block" "priv" {
  count  = var.block_public_access && !var.host_website ? 1 : 0
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

data "aws_iam_policy_document" "bucket_policy" {
  count = !var.host_website && var.allow_encrypted_uploads_only ? 1 : 0

  statement {
    sid       = "DenyIncorrectEncryptionHeader"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${join("", aws_s3_bucket.this.*.id)}/*"]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "StringNotEquals"
      values   = [var.sse_algorithm]
      variable = "s3:x-amz-server-side-encryption"
    }
  }

  statement {
    sid       = "DenyUnEncryptedObjectUploads"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.this.id}/*"]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "Null"
      values   = ["true"]
      variable = "s3:x-amz-server-side-encryption"
    }
  }
}

resource "aws_s3_bucket_policy" "default" {
  count  = !var.host_website && var.allow_encrypted_uploads_only ? 1 : 0
  bucket = join("", aws_s3_bucket.this.*.id)
  policy = join("", data.aws_iam_policy_document.bucket_policy.*.json)
}

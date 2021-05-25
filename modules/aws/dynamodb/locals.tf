locals {
  base_attributes = [
    {
      name = var.range_key
      type = var.range_key_type
    },
    {
      name = var.hash_key
      type = var.hash_key_type
    }
  ]

  attributes = concat(var.additional_attributes, local.base_attributes)

  from_index      = length(var.range_key) > 0 ? 0 : 1
  attributes_list = slice(local.attributes, local.from_index, length(local.attributes))
}


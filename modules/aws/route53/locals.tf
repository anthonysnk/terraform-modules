locals {
  zones                        = var.name == null ? [] : try(tolist(var.name), [tostring(var.name)], [])
  skip_zone_creation           = length(local.zones) == 0
  run_in_vpc                   = length(var.vpc_ids) > 0
  skip_delegation_set_creation = !var.module_enabled || local.skip_zone_creation || local.run_in_vpc ? true : var.skip_delegation_set_creation
  delegation_set_id            = var.delegation_set_id != null ? var.delegation_set_id: try(aws_route53_delegation_set.aws-delegation-set[0].id, null) # if we do not set the id, It will not create it

  /* acm variables  */
  domain_name                   = var.domain_name != null ? var.domain_name : null
  zone_id_acm                   = var.zone_id_acm != null ? var.zone_id_acm : null
  skip_acm_certificate_creation = var.skip_acm_certificate_creation ? var.skip_acm_certificate_creation : false
}

locals {
  records_expanded = {
    for i, record in var.records : join("-", compact([
      lower(record.type),
      try(lower(record.set_identifier), ""),
      try(lower(record.failover), ""),
      try(lower(record.name), ""),
      ])) => {
      type = record.type
      name = try(record.name, "")
      ttl  = try(record.ttl, null)
      alias = {
        name                   = try(record.alias.name, null)
        zone_id                = try(record.alias.zone_id, null)
        evaluate_target_health = try(record.alias.evaluate_target_health, null)
      }
      allow_overwrite = try(record.allow_overwrite, var.allow_overwrite)
      health_check_id = try(record.health_check_id, null)
      idx             = i
      set_identifier  = try(record.set_identifier, null)
      weight          = try(record.weight, null)
      failover        = try(record.failover, null)
    }
  }

  records_by_name = {
    for product in setproduct(local.zones, keys(local.records_expanded)) : "${product[1]}-${product[0]}" => {
      zone_id         = try(aws_route53_zone.aws-zone[product[0]].id, null)
      type            = local.records_expanded[product[1]].type
      name            = local.records_expanded[product[1]].name
      ttl             = local.records_expanded[product[1]].ttl
      alias           = local.records_expanded[product[1]].alias
      allow_overwrite = local.records_expanded[product[1]].allow_overwrite
      health_check_id = local.records_expanded[product[1]].health_check_id
      idx             = local.records_expanded[product[1]].idx
      set_identifier  = local.records_expanded[product[1]].set_identifier
      weight          = local.records_expanded[product[1]].weight
      failover        = local.records_expanded[product[1]].failover
    }
  }

  records_by_zone_id = {
    for id, record in local.records_expanded : id => {
      zone_id         = var.zone_id
      type            = record.type
      name            = record.name
      ttl             = record.ttl
      alias           = record.alias
      allow_overwrite = record.allow_overwrite
      health_check_id = record.health_check_id
      idx             = record.idx
      set_identifier  = record.set_identifier
      weight          = record.weight
      failover        = record.failover
    }
  }

  records = local.skip_zone_creation ? local.records_by_zone_id : local.records_by_name
}

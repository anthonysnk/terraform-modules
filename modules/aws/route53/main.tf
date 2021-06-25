/* Creating delegation to use the same name_server in multiple zones */

resource "aws_route53_delegation_set" "aws-delegation-set" {
  count          = local.skip_delegation_set_creation ? 0 : 1
  reference_name = var.reference_name
  depends_on     = [var.module_depends_on]
}

/* cfreating aws zones  */

resource "aws_route53_zone" "aws-zone" {
  for_each          = var.module_enabled ? toset(local.zones) : []
  name              = each.value
  comment           = var.comment
  force_destroy     = var.force_destroy
  delegation_set_id = local.delegation_set_id

  dynamic "vpc" {
    for_each = { for id in var.vpc_ids : id => id }

    content {
      vpc_id = vpc.value
    }
  }

  tags       = merge({ Name = each.value }, var.tags)
  depends_on = [var.module_depends_on]
}

/* dinamic records  */

resource "aws_route53_record" "aws-record" {
  for_each = var.module_enabled ? local.records : {}

  zone_id         = each.value.zone_id
  type            = each.value.type
  name            = each.value.name
  allow_overwrite = each.value.allow_overwrite
  health_check_id = each.value.health_check_id
  set_identifier  = each.value.set_identifier
  ttl             = each.value.ttl == null && each.value.alias.name == null ? var.default_ttl : each.value.ttl

  /* split TXT records at 255 chars to support >255 char records */
  records = can(var.records[each.value.idx].records) ? [for r in var.records[each.value.idx].records :
    each.value.type == "TXT" && length(regexall("(\\\"\\\")", r)) == 0 ?
    join("\"\"", compact(split("{SPLITHERE}", replace(r, "/(.{255})/", "$1{SPLITHERE}")))) : r
  ] : null

  dynamic "weighted_routing_policy" {
    for_each = each.value.weight == null ? [] : [each.value.weight]

    content {
      weight = weighted_routing_policy.value
    }
  }

  dynamic "failover_routing_policy" {
    for_each = each.value.failover == null ? [] : [each.value.failover]

    content {
      type = failover_routing_policy.value
    }
  }

  dynamic "alias" {
    for_each = each.value.alias.name == null ? [] : [each.value.alias]

    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  depends_on = [var.module_depends_on]
}

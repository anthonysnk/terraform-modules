- [Terraform module for Route53](#terraform-module-for-route53)
  - [How to do basic routing](#how-to-do-basic-routing)
  - [How to deploy delegation set](#how-to-deploy-delegation-set)
  - [How to deploy failover routing](#how-to-deploy-failover-routing)
  - [How to deploy multiple domains with different records](#how-to-deploy-multiple-domains-with-different-records)
  - [How to deploy multiple domains same records](#how-to-deploy-multiple-domains-same-records)
  - [How to deploy private hosted zone](#how-to-deploy-private-hosted-zone)
  - [How to deploy weighted routing](#how-to-deploy-weighted-routing)

# Terraform module for Route53

If you need to understand all option to call api for route53, go to [route-53-documentacion](https://docs.aws.amazon.com/Route53/latest/APIReference/API-actions-by-function.html#actions-by-function-reusable-delegation-sets1).T o review all concept that you can use with route53 visit [concepts](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/route-53-concepts.html)

This module creates one or multiple Route53 zo$nes with associated records and a delegation set.

## How to do basic routing

```hcl
module "route53" {
  source  = "../../modules/route53"
  name = "applaudo-studios-zone.io"

  records = [
    {
      # We don't explicitly need to set names for records that match the zone
      type = "A"
      alias = {
        name                   = aws_s3_bucket.website.website_endpoint
        zone_id                = aws_s3_bucket.website.hosted_zone_id
        evaluate_target_health = true
      }
    },
   {
      type = "CNAME"
      name = "www"
      records = [
        "applaudo.io"
      ]
    },
    {
      name    = "dev"
      type    = "A"
      ttl     = 1800
      records = ["189.0.23.113"]
    },
    {
      type = "CNAME"
      name = "www.dev.applaudo.io"
      records = [
        "dev.applaudo.io"
      ]
    },
  ]
}
```

## How to deploy delegation set

By default, Route 53 assigns a random selection of name servers to each new hosted zone. To make it easier to migrate DNS service to Route 53 for a large number of domains, you can create a reusable delegation set and then associate the reusable delegation set with new hosted zones.

```hcl
module "route53-zone-with-delegation-set" {
  source  = "../../modules/route53"
  name = "applaudo-studios-delegation-set.io"
}

module "route53-zone" {
  source  = "../../modules/route53"
  name              = "applaudo-studios-zone.com"
  delegation_set_id = module.route53-zone-with-delegation-set.delegation_set.id
}
```

## How to deploy failover routing

This exmaple code configures two Route53 Records with associated healthchecks. Route53 will route the traffic to the secondary record if the healthcheck of the primary record reports an unhealthy status.

```hcl
resource "aws_route53_health_check" "primary" {
  fqdn              = "applaudo.io"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 5
  request_interval  = 30

  tags = {
    Name = "primary-healthcheck"
  }
}

module "route53" {
  source  = "../../modules/route53"

  name                         = "applaudo-zone.io"
  skip_delegation_set_creation = true

  records = [
    {
      type           = "A"
      set_identifier = "primary"
      failover       = "PRIMARY"
      # Non-alias primary records must have an associated health check
      health_check_id = aws_route53_health_check.primary.id
      records = [
        "110.0.113.169"
      ]
    },
    {
      type            = "A"
      set_identifier  = "failover"
      failover        = "SECONDARY"
      health_check_id = null
      records = [
        "110.0.113.169",
        "110.0.113.170"
      ]
    }
  ]
}
```

## How to deploy multiple domains with different records

Creating two zones and different records using the convenient name = [] shortcut. All created zones will share the same delegation set.

```hcl
# Create multiple zones with a single module
module "zones" {
  source  = "../../modules/route53"
  name = [
    "applaudo-studios.io",
    "applaudo-studios.com"
  ]
}

# Create the records for zone a
module "zone_a_records" {
  source  = "../../modules/route53"

  # Wrap the reference to the zone inside a try statement to prevent ugly exceptions if we run terraform destroy
  # without running a successful terraform apply before.

  zone_id = try(module.zones.zone["applaudo-studios.io"].zone_id, null)
  records = [
    {
      type = "TXT"
      ttl  = 300
      records = [
        "Lorem ipsum"
      ]
    }
  ]
}

# Create the records for zone b
module "zone_b_records" {
  source  = "../../modules/route53"

  zone_id = try(module.zones.zone["applaudo-studios.com"].zone_id, null)
  records = [
    {
      type = "TXT"
      ttl  = 600
      records = [
        "Lorem ipsum",
        "Lorem ipsum dolor sit amet"
      ]
    }
  ]
}
```

## How to deploy multiple domains same records

Creating two zones and attach the same set of records to both. The zones will share the same delegation set.

```hcl
module "zones" {
   source  = "../../modules/route53"
  name = [
    "applaudo-studios.io",
    "applaudo-studios.com"
  ]

  records = [
    {
      type = "A"
      ttl  = 3600
      records = [
        "102.0.113.200",
        "102.0.113.201"
      ]
    },
    {
      type = "TXT"
      ttl  = 300
      records = [
        "Lorem ipsum"
      ]
    },
    {
      name = "testing"
      type = "A"
      ttl  = 3600
      records = [
        "102.0.113.202"
      ]
    },
  ]
}
```

## How to deploy private hosted zone

Creating a private Route53 Zone with a single A-Record.

```hcl
module "route53" {
  source  = "../../modules/route53"
  name =  "applaudo-studios.io"

  vpc_ids = [
    "vpc-ee178793",
  ]
  records = [
    {
      type = "A"
      ttl  = 3600
      records = [
        "203.0.113.100",
        "203.0.113.101",
      ]
    }
  ]
}
```

## How to deploy weighted routing

Creating a Route53 Zone with two attached weighted records.

```hcl

module "route53" {
  source  = "../../modules/route53"
  name    =  "applaudo-studios.io"
  
  skip_delegation_set_creation = true

  records = [
    {
      type           = "A"
      set_identifier = "prod"
      weight         = 90
      records = [
        "203.0.113.0",
        "203.0.113.1"
      ]
    },
    {
      type           = "A"
      set_identifier = "preview"
      weight         = 10
      records = [
        "216.239.32.117",
      ]
    },
    {
      type = "A"
      name = "dev"
      records = [
        "203.0.113.3",
      ]
    }
  ]
}
```

>applaudo studios

AWS DynamoDB Lock table creation Terraform module
========================

Terraform module which creates a DynamoDB table to provide terraform the capability of locking the state and prevent corruption on multiple runs at the same time.

Usage
-----
You'll need to have your AWS_PROFILE loaded up. Once you do, the module will ask you for the variables that you'll want to set as seen below (e.g.):

Basic usage:
```hcl
module "simple_table" {
  source = "../../modules/aws/dynamodb"

  table_name = "terraform_example"

  environment = "dev"
}
```

With provisioned capacity and auto-scaling:
```hcl
module "simple_table_autoscaling" {
  source = "../../modules/aws/dynamodb"

  table_name = "terraform_lock"

  environment = "dev"

  billing_mode        = "PROVISIONED"
  base_read_capacity  = 3
  max_read_capacity   = 300
  base_write_capacity = 3
  max_write_capacity  = 300
}

output "table_name" {
  value = module.lock_table.table_name
}

output "table_id" {
  value = module.lock_table.table_id
}

output "table_arn" {
  value = module.lock_table.table_arn
}
```

Global table:
```hcl
module "simple_table_global" {
  source = "../../modules/aws/dynamodb"

  environment         = "dev"
  enable_global_table = true
  enable_streams      = true

  table_name = "example_global"

  hash_key = "ID"

  additional_attributes = [
    {
      name = "ID"
      type = "S"
    },
  ]

  items_file = "data/records.json"

  # local_secondary_index_map = [
  #   {
  #     name               = "MyAttributeIndex"
  #     range_key          = "MyAttribute"
  #     projection_type    = "INCLUDE"
  #     non_key_attributes = ["HashKey", "RangeKey"]
  #   },
  # ]

  # global_secondary_index_map = [
  #   {
  #     name            = "MyAttributeIndexGlobal"
  #     hash_key        = "MyAttribute"
  #     write_capacity  = 5
  #     read_capacity   = 5
  #     projection_type = "KEYS_ONLY"
  #   },
  # ]
}

output "local_table_default_name" {
  value = module.simple_table_global.local_table_default_name
}

output "local_table_default_id" {
  value = module.simple_table_global.local_table_default_id
}

output "local_table_default_arn" {
  value = module.simple_table_global.local_table_default_arn
}

output "local_table_default_replica_name" {
  value = module.simple_table_global.local_table_default_replica_name
}

output "local_table_default_replica_id" {
  value = module.simple_table_global.local_table_default_replica_id
}

output "local_table_default_replica_arn" {
  value = module.simple_table_global.local_table_default_replica_arn
}

output "global_table_name" {
  value = module.simple_table_global.global_table_name
}

output "global_table_id" {
  value = module.simple_table_global.global_table_id
}

output "global_table_arn" {
  value = module.simple_table_global.global_table_arn
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional\_attributes | Additional attributes as list of mapped values | list | `<list>` | no |
| base\_read\_capacity | The read capacity in provisioned mode for the DynamoDB table | string | `"5"` | no |
| base\_write\_capacity | The write capacity in provisioned mode for the DynamoDB table | string | `"5"` | no |
| billing\_mode | The billing mode for the DynamoDB table [PAY_PER_REQUEST|PROVISIONED] | string | `"PAY_PER_REQUEST"` | no |
| enable\_encryption | Enable encryption at rest | string | `"true"` | no |
| enable\_global\_table | Enable global table | string | `"false"` | no |
| enable\_point\_in\_time\_recovery | Enable point in time recovery | string | `"true"` | no |
| enable\_streams | Enable streams, required for global tables | string | `"true"` | no |
| enable\_ttl | Enable TTL | string | `"true"` | no |
| environment | Defines in wich environment we are going to work. | string | n/a | yes |
| global\_secondary\_index\_map | Additional global secondary indexes in the form of a list of mapped values | list | `<list>` | no |
| hash\_key | The hash key of the DynamoDB table | string | `"LockID"` | no |
| hash\_key\_type | The hash key type of the DynamoDB table | string | `"S"` | no |
| items\_file | Sample records to insert at creation time | string | `""` | no |
| local\_secondary\_index\_map | Additional local secondary indexes in the form of a list of mapped values | list | `<list>` | no |
| max\_read\_capacity | The max read capacity in provisioned mode for the DynamoDB table | string | `"50"` | no |
| max\_write\_capacity | The max write capacity in provisioned mode for the DynamoDB table | string | `"50"` | no |
| range\_key | DynamoDB table Range Key | string | `""` | no |
| range\_key\_type | Range Key type, which must be a scalar type: `S`, `N`, or `B` for (S)tring, (N)umber or (B)inary data | string | `"S"` | no |
| region | The region to deploy the table | string | `"us-east-1"` | no |
| secondary\_region | The region to deploy the table | string | `"us-west-1"` | no |
| stream\_view\_type | Enable streams [KEYS_ONLY|NEW_IMAGE|OLD_IMAGE|NEW_AND_OLD_IMAGES], NEW_AND_OLD_IMAGES is required for global tables | string | `"NEW_AND_OLD_IMAGES"` | no |
| table\_name | The name of the DynamoDB table | string | `"terraform_locks"` | no |
| tags | A map of tags to be added to the user. | map | `<map>` | no |
| target\_utilization\_value | The target utilization value before the autoscaler kicks in | string | `"75"` | no |
| ttl\_attribute\_name | DynamoDB table TTL attribute name | string | `"Expires"` | no |

## Outputs

| Name | Description |
|------|-------------|
| global\_table\_arn | DynamoDB global table arn |
| global\_table\_id | DynamoDB global table id |
| global\_table\_name | DynamoDB global table name |
| local\_table\_default\_arn | DynamoDB table ARN |
| local\_table\_default\_id | DynamoDB table ID |
| local\_table\_default\_name | DynamoDB table name |
| local\_table\_default\_replica\_arn | DynamoDB table ARN |
| local\_table\_default\_replica\_id | DynamoDB table ID |
| local\_table\_default\_replica\_name | DynamoDB table name |

Applaudo Studios 2021.

# Terraform module for AWS ECR

Terraform module that deploys a container registry.  

This module can be configured to scan docker images on push for security vulnerabilities.

This module allows to stablish AWS Accounts to validate access (Cross account access)

## Basic usage example

```hcl
provider "aws" {
  region = "us-east-1"
}

locals {
  repos = [
    {
      name       = "test-a"
      mutable    = true
      image_scan = false
    },
    {
      name       = "test-b"
      mutable    = false
      image_scan = true
    }
  ]
}

module "ecr_repo" {
  source = "../../modules/ecr"

  repos                 = local.repos
  resource_based_policy = true
  allowed_account_ids   = ["your_account_id"]
}
```

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 0.15 |

## Providers

| Name | Version |
| ---- | ------- |
| aws  | n/a     |

## Inputs

| Name                  | Description                                                                   | Type                                                                 | Default | Required |
| --------------------- | ----------------------------------------------------------------------------- | -------------------------------------------------------------------- | ------- | :------: |
| allowed_account_ids   | A list of AWS Account IDs to give access to pull/push images from/to the repo | `list(string)`                                                       | `[]`    |    no    |
| repos                 | The list of repos to allocate.                                                | `list(object({ name = string, mutable = bool, image_scan = bool }))` | `[]`    |    no    |
| resource_based_policy | True if we want to attach a resource-based policy allowing push/pull actions  | `bool`                                                               | `true`  |    no    |
| tags                  | A map of tags to assign to the registry                                       | `map(string)`                                                        | `{}`    |    no    |

## Outputs

| Name     | Description             |
| -------- | ----------------------- |
| repo_arn | The arn of the ecr repo |

Applaudo Studios 

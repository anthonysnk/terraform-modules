# Terraform module for AWS VPC

Terraform module which deploys an AWS VPC in a given AWS region.

The module creates one public and one private subnet per Availability Zone. The
AZs to deploy the subnets into as well as the CIDR ranges for each subnet has to
be passed as a module argument. It also supports the creation of database subnets,
which are private inside the VPC.

ACLs tables for public and private subnets are created with a set of rules enabled
by default:
- ALL Outbound traffic (any port, any destination) is allowed
- Any Inbound traffic is allowed if it was originated inside the VPC
- Return (Inbound) traffic to udp/tcp ephemeral ports (1024-65535) is also permitted.
This is for allowing the return traffic of communications originated from the VPC
to outside (like software updates).

The module supports we specify any custom Inbound rule we want to permit for ACLs
associated with public and private subnets.


## Basic usage example

```hcl
module "vpc" {
  source    = "./modules/vpc"

  environment = terraform.workspace

  # Network settings
  vpc_cidr              = "10.0.0.0/16"
  azs                   = ["us-east-1a", "us-east-1b"]
  public_subnets_cidrs  = ["10.0.0.0/23", "10.0.2.0/23"]
  private_subnets_cidrs = ["10.0.10.0/23", "10.0.12.0/23"]
  db_subnets_cidrs      = ["10.0.20.0/24", "10.0.21.0/24"]
  # Creates a NAT Gateway between private and public subnets
  enable_nat_gw         = true
  # Make only a single NAT Gateway for all AZs, rather than 1 for each AZ
  single_nat_gw         = true


  # Security settings: custom ACL rules for public subnets
  allow_inbound_traffic_public_subnet = [
    {
      protocol  = "tcp"
      from_port = 443
      to_port   = 443
      source    = "0.0.0.0/0"
    },
  ]

  # Tagging
  tags = {
    environment = "${terraform.workspace}"
    App         = "App1"
  }

}
```
## Inputs

| Name                                              | Description                                                                                                                                           |  Type  |       Default       | Required |
|---------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|:------:|:-------------------:|:--------:|
| allow\_inbound\_traffic\_default\_private\_subnet | A list of maps of inbound traffic allowed by default for private subnets                                                                              |  list  |      `<list>`       |    no    |
| allow\_inbound\_traffic\_default\_public\_subnet  | A list of maps of inbound traffic allowed by default for public subnets                                                                               |  list  |      `<list>`       |    no    |
| allow\_inbound\_traffic\_private\_subnet          | The ingress traffic the customer needs to allow for private subnets                                                                                   |  list  |      `<list>`       |    no    |
| allow\_inbound\_traffic\_public\_subnet           | The inbound traffic the customer needs to allow for public subnets                                                                                    |  list  |      `<list>`       |    no    |
| auto\_accept\_shared\_attachments                 | Whether resource attachment requests are automatically accepted.                                                                                      | string |     `"disable"`     |    no    |
| azs                                               | A list of Availability Zones to use in a specific Region                                                                                              |  list  |         n/a         |   yes    |
| eks\_network\_tags                                | A map of tags needed by EKS to identify the VPC and subnets                                                                                           |  map   |       `<map>`       |    no    |
| eks\_private\_subnet\_tags                        | A map of tags needed by EKS to identify private subnets for internal LBs                                                                              |  map   |       `<map>`       |    no    |
| enable\_dns\_hostnames                            | True if DNS hostnames is enabled in the VPC                                                                                                           | string |      `"true"`       |    no    |
| enable\_dns\_support                              | True if the DNS support is enabled in the VPC                                                                                                         | string |      `"true"`       |    no    |
| enable\_igw                                       | True if you want an igw added to your public route table                                                                                              | string |      `"true"`       |    no    |
| enable\_nacls                                     | Enable creation of restricted-by-default network acls.                                                                                                | string |      `"true"`       |    no    |
| enable\_nat\_gw                                   | True if we want to create at least one NAT-gw for private subnets                                                                                     | string |      `"true"`       |    no    |
| environment                                       | Name of the environment (terraform.workspace or static environment name for vpcs not managed with a workspace)                                        | string |        `""`         |    no    |
| icmp\_diagnostics\_enable                         | Enable full icmp for diagnostic purposes                                                                                                              | string |      `"false"`      |    no    |
| instance\_tenancy                                 | The type of tenancy for EC2 instances launched into the VPC                                                                                           | string |     `"default"`     |    no    |
| map\_to\_public\_ip                               | True if public IPs are assigned to instances launched in a subnet                                                                                     | string |      `"false"`      |    no    |
| private\_subnet\_cidrs                            | A list of the CIDR ranges to use for private subnets                                                                                                  |  list  |      `<list>`       |    no    |
| public\_subnet\_cidrs                             | A list of the CIDR ranges to use for public subnets                                                                                                   |  list  |      `<list>`       |    no    |
| region                                            | The AWS region we wish to provision in, by default                                                                                                    | string |    `"us-east-1"`    |    no    |
| single\_nat\_gw                                   | If true, all private and database subnets will share 1 Route Table and NAT GW.  If false, one NAT-gw per AZ will be created along with one RT per AZ. | string |      `"true"`       |    no    |
| tags                                              | A map of tags for the VPC resources                                                                                                                   |  map   |       `<map>`       |    no    |
| vpc\_cidr                                         | The CIDR range for the VPC                                                                                                                            | string |         n/a         |   yes    |
| vpn\_ecmp\_support                                | Whether VPN Equal Cost Multipath Protocol support is enabled.                                                                                         | string |     `"disable"`     |    no    |

## Outputs

| Name                             | Description                                                   |
|----------------------------------|---------------------------------------------------------------|
| azs                              | List of Availability Zones provisioned within                 |
| database\_subnets\_azs           | List of the AZ for the subnet                                 |
| db\_subnet\_cidrs                | List of database subnet cidr blocks provisioned               |
| db\_subnet\_ids                  | List of database subnet IDs provisioned                       |
| environment                      | Name of the environment we provisioned the VPC for            |
| igw\_id                          | Internet Gateway ID provisioned                               |
| nat\_gw\_ids                     | List of NAT Gateway IDs provisioned                           |
| private\_subnet\_cidrs           | List of private subnet cidr blocks provisioned                |
| private\_subnet\_ids             | List of private subnet IDs provisioned                        |
| public\_subnet\_cidrs            | List of public subnet cidr blocks provisioned                 |
| public\_subnet\_ids              | List of public subnet IDs provisioned                         |
| vpc\_cidr                        | CIDR of the overall environment config (covering all subnets) |
| vpc\_id                          | ID of the provisioned VPC                                     |


Applaudo 2021


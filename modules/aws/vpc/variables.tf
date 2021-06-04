# -------------------------------------------------------------
# Network variables
# -------------------------------------------------------------

variable "region" {
  description = "The AWS region we wish to provision in, by default"
  type        = string
}

variable "environment" {
  description = "Name of the environment (terraform.workspace or static environment name for vpcs not managed with a workspace)"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR range for the VPC"
  type        = string
}

variable "enable_dns_support" {
  description = "True if the DNS support is enabled in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "True if DNS hostnames is enabled in the VPC"
  type        = bool
  default     = true
}

variable "instance_tenancy" {
  description = "The type of tenancy for EC2 instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "map_to_public_ip" {
  description = "True if public IPs are assigned to instances launched in a subnet"
  type        = bool
  default     = false
}

variable "azs" {
  description = "A list of Availability Zones to use in a specific Region"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "A list of the CIDR ranges to use for public subnets"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "A list of the CIDR ranges to use for private subnets"
  type        = list(string)
  default     = []
}

variable "db_subnet_cidrs" {
  description = "A list of the CIDR ranges for database subnets"
  type        = list(string)
  default     = []
}

variable "enable_nat_gw" {
  description = "True if we want to create at least one NAT-gw for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gw" {
  description = "If true, all private and database subnets will share 1 Route Table and NAT GW.  If false, one NAT-gw per AZ will be created along with one RT per AZ."
  type        = bool
  default     = true
}

variable "enable_igw" {
  description = "True if you want an igw added to your public route table"
  type        = bool
  default     = true
}

variable "default_route_table_association" {
  description = "Whether resource attachments are automatically associated with the default association route table."
  type        = string
  default     = "enable"
}

variable "default_route_table_propagation" {
  description = "Whether resource attachments automatically propagate routes to the default propagation route table."
  type        = string
  default     = "enable"
}

variable "auto_accept_shared_attachments" {
  description = "Whether resource attachment requests are automatically accepted."
  type        = string
  default     = "disable"
}

variable "vpn_ecmp_support" {
  description = "Whether VPN Equal Cost Multipath Protocol support is enabled."
  type        = string
  default     = "disable"
}

# -------------------------------------------------------------
# Security variables
# -------------------------------------------------------------
variable "icmp_diagnostics_enable" {
  description = "Enable full icmp for diagnostic purposes"
  type        = bool
  default     = false
}

variable "enable_nacls" {
  description = "Enable creation of restricted-by-default network acls."
  type        = bool
  default     = true
}

variable "allow_inbound_traffic_default_public_subnet" {
  description = "A list of maps of inbound traffic allowed by default for public subnets"
  type = list(object({
    protocol  = string
    from_port = number
    to_port   = number
    source    = string
  }))

  default = [
    {
      # ephemeral tcp ports (allow return traffic for software updates to work)
      protocol  = "tcp"
      from_port = 1024
      to_port   = 65535
      source    = "0.0.0.0/0"
    },
    {
      # ephemeral udp ports (allow return traffic for software updates to work)
      protocol  = "udp"
      from_port = 1024
      to_port   = 65535
      source    = "0.0.0.0/0"
    },
  ]
}

variable "allow_inbound_traffic_public_subnet" {
  description = "The inbound traffic the customer needs to allow for public subnets"
  type = list(object({
    protocol  = string
    from_port = number
    to_port   = number
    source    = string
  }))
  default = []
}

variable "allow_inbound_traffic_default_private_subnet" {
  description = "A list of maps of inbound traffic allowed by default for private subnets"
  type = list(object({
    protocol  = string
    from_port = number
    to_port   = number
    source    = string
  }))

  default = [
    {
      # ephemeral tcp ports (allow return traffic for software updates to work)
      protocol  = "tcp"
      from_port = 1024
      to_port   = 65535
      source    = "0.0.0.0/0"
    },
    {
      # ephemeral udp ports (allow return traffic for software updates to work)
      protocol  = "udp"
      from_port = 1024
      to_port   = 65535
      source    = "0.0.0.0/0"
    },
  ]
}

variable "allow_inbound_traffic_private_subnet" {
  description = "The ingress traffic the customer needs to allow for private subnets"
  type = list(object({
    protocol  = string
    from_port = number
    to_port   = number
    source    = string
  }))
  default = []
}


# -------------------------------------------------------------
# Tagging
# -------------------------------------------------------------

variable "tags" {
  description = "A map of tags for the VPC resources"
  type        = map(string)
  default     = {}
}

variable "eks_network_tags" {
  description = "A map of tags needed by EKS to identify the VPC and subnets"
  type        = map(string)
  default     = {}
}

variable "eks_public_subnet_tags" {
  description = "A map of tags needed by EKS to identify the public subnets for public LBs"
  type        = map(string)
  default     = {}
}

variable "eks_private_subnet_tags" {
  description = "A map of tags needed by EKS to identify private subnets for internal LBs"
  type        = map(string)
  default     = {}
}

# VPC Endpoints

variable "s3_endpoint" {
  description = "Enable the creation of a s3 vpc endpoint"
  type        = bool
  default     = true
}

variable "dynamodb_endpoint" {
  description = "Enable the creation of a dynamodb vpc endpoint"
  type        = bool
  default     = false
}

variable "interface_endpoint_services" {
  description = "List of interface service endpoints to be created in the VPC"
  type        = list(string)
  default     = []
}

# VPC Flow Logs

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow logs "
  type        = bool
  default     = false
}

variable "log_destination" {
  description = "The ARN of the logging destination"
  type        = string
}

variable "log_destination_type" {
  description = "The type of the logging destination, Valid values: cloud-watch-logs, s3"
  type        = string
}

variable "traffic_type" {
  description = "The type of traffic to capture, Valid values: ACCEPT,REJECT, ALL"
  type        = string
  default     = "ALL"
}

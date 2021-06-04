# --------------------------------------------------------------------
# Virtual Private Cloud (VPC) network resources
# --------------------------------------------------------------------

###
# Virtual Private Cloud (VPC)
###
resource "aws_vpc" "this" {
  provider             = aws.vpc
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  instance_tenancy     = var.instance_tenancy
  tags = merge(
    {
      "Name" = "${var.environment}-vpc"
    },
    var.tags,
    var.eks_network_tags,
  )
}

###
# Internet Gateway
###
resource "aws_internet_gateway" "this" {
  count    = length(var.public_subnet_cidrs) > 0 && var.enable_igw ? 1 : 0
  provider = aws.vpc
  vpc_id   = aws_vpc.this.id
  tags = merge(
    {
      "Name" = "${var.environment}-igw"
    },
    var.tags,
  )
}

###
# NAT Gateway(s)
###

resource "aws_nat_gateway" "nat_gw" {
  count         = var.enable_nat_gw && var.enable_igw ? local.nat_gw_count : 0
  provider      = aws.vpc
  allocation_id = element(aws_eip.elastic_ip.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnets.*.id, count.index)
  tags = merge(
    {
      "Name" = "${var.environment}-natgw-${count.index + 1}"
    },
    var.tags,
  )
}

###
# Elastic IP(s) for NAT Gateway(s) 
# --------------------------------
# See NAT Gateway(s) for the logic on enable_igw
###
resource "aws_eip" "elastic_ip" {
  count    = var.enable_nat_gw && var.enable_igw ? local.nat_gw_count : 0
  provider = aws.vpc
  vpc      = true
  tags = merge(
    {
      "Name" = "${var.environment}-natgw-elasticIP-${count.index + 1}"
    },
    var.tags,
  )
}

###
# Public Subnets
###
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  provider                = aws.vpc
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.azs, count.index % length(var.azs))
  map_public_ip_on_launch = var.map_to_public_ip
  tags = merge(
    {
      "Name" = "${var.environment}-public-${element(var.azs, count.index)}-subnet"
    },
    var.tags,
    var.eks_network_tags,
    var.eks_public_subnet_tags,
  )
}

###
# Private Subnets
###
resource "aws_subnet" "private_subnets" {
  count                   = length(var.private_subnet_cidrs)
  provider                = aws.vpc
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  availability_zone       = element(var.azs, count.index % length(var.azs))
  map_public_ip_on_launch = false
  tags = merge(
    {
      "Name" = "${var.environment}-private-${element(var.azs, count.index)}-subnet"
    },
    var.tags,
    var.eks_network_tags,
    var.eks_private_subnet_tags,
  )
}

###
# Database Subnets (private)
###
resource "aws_subnet" "private_db_subnets" {
  count                   = length(var.db_subnet_cidrs)
  provider                = aws.vpc
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.db_subnet_cidrs, count.index)
  availability_zone       = element(var.azs, count.index % length(var.azs))
  map_public_ip_on_launch = false
  tags = merge(
    {
      "Name" = "${var.environment}-db-${element(var.azs, count.index)}-subnet"
    },
    var.tags,
  )
}

###
# Route table for public subnets
###
resource "aws_route_table" "public" {
  count    = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  provider = aws.vpc
  vpc_id   = aws_vpc.this.id
  tags = merge(
    {
      "Name" = "${var.environment}-rt-public"
    },
    var.tags,
  )
}

###
# Route table(s) for private subnets
# ----------------------------------
# This is rather variable:
#       a) Create RT only if we have private and/or db subnets defined 
#       b) If var.single_nat_gw is 'true', we make 1 RT for all non-public subnets
#       c) If var.single_nat_gw is 'false', we make 1 RT per defined AZ in ${var.azs}
resource "aws_route_table" "private" {
  count    = length(var.private_subnet_cidrs) > 0 || length(var.db_subnet_cidrs) > 0 ? local.nat_gw_count : 0
  provider = aws.vpc
  vpc_id   = aws_vpc.this.id
  tags = merge(
    {
      "Name" = "${var.environment}-rt-private_subnets-${count.index + 1}"
    },
    var.tags,
  )
}

###
# Associate route table with public subnets
# -----------------------------------------
###
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs) > 0 ? length(var.public_subnet_cidrs) : 0
  provider       = aws.vpc
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

###
# Associate private route table(s) with private subnets
###
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs) > 0 ? length(var.private_subnet_cidrs) : 0
  provider       = aws.vpc
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

###
# Associate private route table(s) with database subnets
###
resource "aws_route_table_association" "db_subnets" {
  count          = length(var.db_subnet_cidrs) > 0 ? length(var.db_subnet_cidrs) : 0
  provider       = aws.vpc
  subnet_id      = element(aws_subnet.private_db_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

###
# VPC Main Route Table association
# --------------------------------
###
resource "aws_main_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs) > 0 ? 1 : 0
  provider       = aws.vpc
  vpc_id         = aws_vpc.this.id
  route_table_id = element(aws_route_table.private.*.id, 0)
}

###
# If public subnets exist, but no private subnets exist, then force the public route table to be 
# the main route table for the VPC
###
resource "aws_main_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs) > 0 && length(var.private_subnet_cidrs) == 0 ? 1 : 0
  provider       = aws.vpc
  vpc_id         = aws_vpc.this.id
  route_table_id = aws_route_table.public[0].id
}

###
resource "aws_main_route_table_association" "db_private" {
  count          = length(var.db_subnet_cidrs) > 0 && length(var.private_subnet_cidrs) == 0 && length(var.public_subnet_cidrs) == 0 ? 1 : 0
  provider       = aws.vpc
  vpc_id         = aws_vpc.this.id
  route_table_id = aws_route_table.private[0].id
}

###
# Route(s) to Internet through the NAT Gateway(s)
###
resource "aws_route" "nat_gw_route" {
  count                  = var.enable_nat_gw ? local.nat_gw_count : 0
  provider               = aws.vpc
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_gw.*.id, count.index)
}

###
# Route(s) to the internet from the Public Route Table if enable_igw is true
###
resource "aws_route" "igw_default_route" {
  count                  = var.enable_igw && length(var.public_subnet_cidrs) > 0 ? 1 : 0
  provider               = aws.vpc
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

# VPC endpoints
data "aws_vpc_endpoint_service" "s3" {
  count        = var.s3_endpoint ? 1 : 0
  provider     = aws.vpc
  service      = "s3"
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "s3" {
  count           = var.s3_endpoint ? 1 : 0
  provider        = aws.vpc
  vpc_id          = aws_vpc.this.id
  service_name    = data.aws_vpc_endpoint_service.s3[0].service_name
  route_table_ids = concat(aws_route_table.private.*.id, aws_route_table.public.*.id)
}

data "aws_vpc_endpoint_service" "dynamodb" {
  count        = var.dynamodb_endpoint ? 1 : 0
  provider     = aws.vpc
  service      = "dynamodb"
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "dynamodb" {
  count           = var.dynamodb_endpoint ? 1 : 0
  provider        = aws.vpc
  vpc_id          = aws_vpc.this.id
  service_name    = data.aws_vpc_endpoint_service.dynamodb[0].service_name
  route_table_ids = concat(aws_route_table.private.*.id, aws_route_table.public.*.id)
}

# Interface endpoints
data "aws_vpc_endpoint_service" "interface" {
  count    = length(var.interface_endpoint_services)
  provider = aws.vpc
  service  = var.interface_endpoint_services[count.index]
}

resource "aws_vpc_endpoint" "interface" {
  count             = length(var.interface_endpoint_services)
  provider          = aws.vpc
  vpc_id            = aws_vpc.this.id
  service_name      = data.aws_vpc_endpoint_service.interface[count.index].service_name
  vpc_endpoint_type = "Interface"
  subnet_ids        = data.aws_subnet_ids.private_subnets[count.index].ids

  security_group_ids = [
    aws_security_group.interface_endpoint[0].id,
  ]

  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_security_group" "interface_endpoint" {
  count    = length(var.interface_endpoint_services) > 0 ? 1 : 0
  provider = aws.vpc
  name     = "interface_endpoints_sg"
  vpc_id   = aws_vpc.this.id
  tags     = var.tags
}

resource "aws_security_group_rule" "interface_endpoint_outbound" {
  count             = length(var.interface_endpoint_services) > 0 ? 1 : 0
  provider          = aws.vpc
  type              = "egress"
  protocol          = -1
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.interface_endpoint[0].id
}

resource "aws_security_group_rule" "interface_endpoint_inbound" {
  count             = length(var.interface_endpoint_services) > 0 ? 1 : 0
  provider          = aws.vpc
  type              = "ingress"
  protocol          = -1
  from_port         = 0
  to_port           = 0
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.interface_endpoint[0].id
}

# VPC Flow logs

resource "aws_flow_log" "this" {
  count                = var.enable_vpc_flow_logs ? 1 : 0
  provider             = aws.vpc
  log_destination      = var.log_destination
  log_destination_type = var.log_destination_type
  traffic_type         = var.traffic_type
  vpc_id               = aws_vpc.this.id
}


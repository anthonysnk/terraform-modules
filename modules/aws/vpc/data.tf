data "aws_vpc_endpoint_service" "this" {
  provider = aws.vpc
  count    = length(var.interface_endpoint_services)
  service  = var.interface_endpoint_services[count.index]
}

data "aws_subnet_ids" "private_subnets" {
  provider = aws.vpc
  count    = length(var.interface_endpoint_services)
  vpc_id   = aws_vpc.this.id

  filter {
    name   = "subnet-id"
    values = aws_subnet.private_subnets.*.id
  }

  filter {
    name   = "availability-zone"
    values = data.aws_vpc_endpoint_service.this[count.index].availability_zones
  }
}

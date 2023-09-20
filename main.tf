resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block

  tags = merge(var.tags, { Name = "${var.env}-vpc" })
}

module "subnets" {
  source = "./subnets"

  for_each          = var.subnets
  vpc_id            = aws_vpc.vpc.id
  name              = each.value["name"]
  cidr_block        = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]

  tags = var.tags
  env  = var.env
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, { Name = "${var.env}-igw" })
}

resource "aws_eip" "elastic_ip" {
  count = length(var.subnets["public"].cidr_block)

  tags = merge(var.tags, { Name = "${var.env}-igw-${count.index+1}" })
}

resource "aws_nat_gateway" "ngw" {
  count         = length(var.subnets["public"].cidr_block)
  allocation_id = aws_eip.elastic_ip[count.index].id
  subnet_id     = module.subnets["public"].subnet_ids[count.index]

  tags = merge(var.tags, { Name = "${var.env}-ngw-${count.index+1}" })
}

resource "aws_route" "route_igw" {
  count                  = length(module.subnets["public"].route_ids)
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = module.subnets["public"].route_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_ngw" {
  count                  = length(local.all_private_subnet)
  nat_gateway_id         = element(aws_nat_gateway.ngw.*.id, count.index)
  route_table_id         = local.all_private_subnet[count.index]
  destination_cidr_block = "0.0.0.0/0"
}


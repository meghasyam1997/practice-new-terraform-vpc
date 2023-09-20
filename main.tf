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

  tags =  merge(var.tags, { Name = "${var.env}-igw" })
}

resource "aws_eip" "elastic_ip" {
  count = length(var.subnets["public"].cidr_block)

  tags =  merge(var.tags, { Name = "${var.env}-igw-${count.index+1}" })
}

#resource "aws_nat_gateway" "ngw" {
#
#  allocation_id = aws_eip.elastic_ip.id
#  subnet_id     = aws_subnet.example.id
#
#  tags = {
#    Name = "gw NAT"
#  }
#}

output "subnets" {
  value = module.subnets
}
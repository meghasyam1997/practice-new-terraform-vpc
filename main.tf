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
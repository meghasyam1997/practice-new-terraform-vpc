output "subnet_ids" {
  value = aws_subnet.subnets.*.id
}

output "route_ids" {
  value = aws_route_table.rt.*.id
}
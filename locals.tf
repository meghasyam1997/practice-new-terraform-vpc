locals {
  all_private_subnet = concat(module.subnets["app"].route_ids,module.subnets["db"].route_ids,module.subnets["web"].route_ids)
}
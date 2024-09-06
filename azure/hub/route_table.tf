module "extra_subnets_route_table" {
  source = "../route-table"
  count  = local.create_extra_subnets_route_table ? 1 : 0

  name                = var.extra_subnets_route_table_name != null ? var.extra_subnets_route_table_name : "rt-hub-${module.network.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  disable_bgp_route_propagation = var.disable_bgp_route_propagation

  subnet_ids = local.subnet_assoc_route_table

  default_route = local.default_route

  routes = var.extra_routes
}
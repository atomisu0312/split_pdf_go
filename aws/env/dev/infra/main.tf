
module "network" {
  source = "../../../modules/network"

  app_vpc_id     = var.app_vpc_id
  route_table_id = var.route_table_id
}


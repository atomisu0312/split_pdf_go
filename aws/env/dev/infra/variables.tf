variable "app_vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "route_table_id" {
  description = "The ID of the route table"
  type        = string
}

variable "region" {
  description = "The region in which the VPC will be created"
  type        = string

}


variable "account_id" {
  type = string
}
variable "region" {
  type = string
}
variable "cluster_arn" {
  type = string
}
variable "security_group_id" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "task_definition_arn" {
  type = string
}
variable "task_role_arn" {
  type = string
}
variable "task_execution_role_arn" {
  type = string
}

variable "num_machine" {
  type = number
}

variable "default_pdf_name" {
  type = string
}
variable "default_bucket_name" {
  type = string
}
module "stepfunctions" {
  source                  = "../../../modules/stepfunctions"
  account_id              = var.account_id
  region                  = var.region
  cluster_arn             = var.cluster_arn
  security_group_id       = var.security_group_id
  subnet_id               = var.subnet_id
  task_definition_arn     = var.task_definition_arn
  task_role_arn           = var.task_role_arn
  task_execution_role_arn = var.task_execution_role_arn
}

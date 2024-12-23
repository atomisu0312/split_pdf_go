module "stepfunctions" {
  source                  = "../../../modules/stepfunctions"
  account_id              = var.account_id
  region                  = var.region
  cluster_arn             = module.ecs.cluster_arn
  vpc_id                  = var.vpc_id
  subnet_id               = var.subnet_id
  task_definition_arn     = module.ecs.task_definition_arn
  task_role_arn           = module.ecs.ecs_role_arn
  task_execution_role_arn = module.ecs.ecs_execution_role_arn
  num_machine             = var.num_machine
}

module "ecs" {
  source    = "../../../modules/ecs"
  image_arn = module.ecr.image_uri
}

module "ecr" {
  source          = "../../../modules/ecr"
  repository_name = var.repository_name
}

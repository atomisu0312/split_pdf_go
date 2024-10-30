terraform {
  backend "s3" {
    bucket = "terraform-split-pdf-go-atomisu"
    key    = "terraform/dev/main"
    region = "ap-northeast-1" # ここにregionを追加
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "network" {
  source = "../../../modules/network"

  app_vpc_id     = var.app_vpc_id
  route_table_id = var.route_table_id
}


/**
module "lambda_image_viewer" {
  source               = "../../../modules/lambda/imageViewer"
  lambda_function_name = "lambda_image_viewer"
  ecr_repository_name  = "img_viewer2_nextjs_action"
  application_port     = "3030"
}

module "lambda_my_good_stuff" {
  source               = "../../../modules/lambda/myGoodStuff"
  lambda_function_name = "my_good_stuff"
  ecr_repository_name  = "my_good_stuff_action"
  application_port     = "3030"
}
**/

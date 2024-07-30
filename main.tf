terraform {
  backend "s3" {
    region  = "eu-west-2"
    encrypt = true
  }

}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}


module "profile_management_outbox_service_ecr" {
  source    = "github.com/PA-NIHR-CRN/terraform-modules//ecr?ref=v1.1.0"
  repo_name = "${var.names["${var.env}"]["accountidentifiers"]}-${var.env}-${var.names["system"]}-outbox-service-ecr"
  env       = var.env
  app       = var.names["${var.env}"]["app"]
  account   = var.names["${var.env}"]["accountidentifiers"]
  system    = var.names["system"]
}

module "lambda_role" {
  source  = "./modules/lambda_ima_role"
  env     = var.env
  system  = var.names["system"]
  account = var.names["${var.env}"]["accountidentifiers"]
}

data "aws_cognito_user_pools" "selected" {
  name = var.names["${var.env}"]["cognito_user_pool_name"]
}

module "lambda_api_function" {
  source          = "github.com/PA-NIHR-CRN/terraform-modules//lambda?ref=v1.1.1"
  function_name   = "${var.account}-lambda-${var.env}-${var.system}-service"
  name_prefix     = var.names["${var.env}"]["accountidentifiers"]
  env             = var.env
  system          = var.system
  timeout         = 30
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnet_ids
  memory_size     = var.memory_size
  handler         = "NIHR.ProfileManagement.Api::NIHR.ProfileManagement.Api.LambdaEntryPoint::FunctionHandlerAsync"
  filename        = "./modules/.build/lambda_dummy/lambda_dummy.zip"
  lambda_role_arn = module.lambda_role.lambda_execution_role_arn
  runtime         = "dotnet8"

  environment_variables = {
    "ProfileManagementApi__JwtBearer__Authority" = "https://${data.aws_cognito_user_pools.selected.endpoint}",
    "Data__ConnectionString"                     = "server=${module.rds_aurora.aurora_db_endpoint};database=${var.db_name};user=${jsondecode(data.aws_secretsmanager_secret_version.terraform_secret_version.secret_string)["db-username"]}",
    "Data__PasswordSecretName"                   = var.rds_password_secret_name
  }

  provisioned_concurrent_executions = 2 # Set to 0 to disable

  tags = {
    Environment = var.env
    System      = var.system
  }
}

data "aws_secretsmanager_secret" "terraform_secret" {
  name = "${var.names["${var.env}"]["accountidentifiers"]}-secret-${var.env}-${var.names["system"]}-terraform"
}

data "aws_secretsmanager_secret_version" "terraform_secret_version" {
  secret_id = data.aws_secretsmanager_secret.terraform_secret.id
}

## RDS DB
module "rds_aurora" {
  source                  = "./modules/auroradb"
  account                 = var.names["${var.env}"]["accountidentifiers"]
  env                     = var.env
  system                  = var.names["system"]
  app                     = var.names["${var.env}"]["app"]
  vpc_id                  = var.names["${var.env}"]["vpcid"]
  engine                  = var.names["${var.env}"]["engine"]
  engine_version          = var.names["${var.env}"]["engine_version"]
  instance_class          = var.names["${var.env}"]["instanceclass"]
  backup_retention_period = var.names["${var.env}"]["backupretentionperiod"]
  maintenance_window      = var.names["${var.env}"]["maintenancewindow"]
  subnet_group            = "${var.names["${var.env}"]["accountidentifiers"]}-rds-sng-${var.env}-public"
  db_name                 = "profile_management"
  username                = jsondecode(data.aws_secretsmanager_secret_version.terraform_secret_version.secret_string)["db-username"]
  instance_count          = var.names["${var.env}"]["rds_instance_count"]
  az_zones                = var.names["${var.env}"]["az_zones"]
  min_capacity            = var.names["${var.env}"]["min_capacity"]
  max_capacity            = var.names["${var.env}"]["max_capacity"]
  skip_final_snapshot     = var.names["${var.env}"]["skip_final_snapshot"]
  log_types               = var.names["${var.env}"]["log_types"]
  publicly_accessible     = var.names["${var.env}"]["publicly_accessible"]
  add_scheduler_tag       = var.names["${var.env}"]["add_scheduler_tag"]
  lambda_sg               = module.lambda_api_function.lambda_sg
  #   signup_lambda_sg        = module.lambda.signup_lambda_sg
  #   ecs_sg                  = module.outbox_processor_ecs.ecs_sg
  ingress_rules     = jsondecode(data.aws_secretsmanager_secret_version.terraform_secret_version.secret_string)["ingress_rules"]
  apply_immediately = var.names["${var.env}"]["apply_immediately"]
}

# module "outbox_processor_ecs" {
#   source               = "./modules/ecs"
#   account              = var.names["${var.env}"]["accountidentifiers"]
#   name                 = "${var.names["${var.env}"]["accountidentifiers"]}-${var.env}-${var.names["system"]}-ecs-outbox-processor"
#   env                  = var.env
#   system               = var.names["system"]
#   vpc_id               = var.names["${var.env}"]["vpcid"]
#   instance_count       = var.names["${var.env}"]["ecs_instance_count"]
#   ecs_subnets          = (var.names["${var.env}"]["private_subnet_ids"])
#   container_name       = "${var.names["${var.env}"]["accountidentifiers"]}-${var.env}-${var.names["system"]}-outbox-container"
#   image_url            = data.aws_ecr_image.outbox_processor_image.image_uri
#   bootstrap_servers    = var.names["${var.env}"]["bootstrap_servers"]
#   ecs_cpu              = var.names["${var.env}"]["ecs_cpu"]
#   ecs_memory           = var.names["${var.env}"]["ecs_memory"]
#   message_bus_topic    = var.names["${var.env}"]["message_bus_topic"]
#   sleep_interval       = var.names["${var.env}"]["sleep_interval"]
#   db_password          = var.names["${var.env}"]["rds_password_secret_name"]
#   rds_cluster_endpoint = module.rds_aurora.aurora_db_endpoint
#   db_name              = var.names["${var.env}"]["db_name"]
#   db_username          = jsondecode(data.aws_secretsmanager_secret_version.terraform_secret_version.secret_string)["db-username"]
#   rds_sg               = module.rds_aurora.rds_sg
# }
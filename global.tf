variable "names" {
  default = {
    "retention_in_days" = "30"
    "proj"              = "nihr"
    "system"            = "rddi-study-management"
    "app"               = "rddi-study-management"

    "dev" = {
      "accountidentifiers"            = "nihrd"
      "environment"                   = "dev"
      "app"                           = "rddi-study-management"
      "backupretentionperiod"         = 7
      "engine"                        = "mysql"
      "engine_version"                = "8.0.mysql_aurora.3.06.0"
      "instanceclass"                 = "db.serverless"
      "skip_final_snapshot"           = true
      "private_subnet_ids"            = ["subnet-036934130e6e171db", "subnet-08301b8a8d127a1e5", "subnet-04c549421f430d61f"] #private subnets
      "vpcid"                         = "vpc-05a9b4ad1477b9b86"
      "maintenancewindow"             = "Sat:04:00-Sat:05:00"
      "storageencrypted"              = true
      "grant_odp_db_access"           = false
      "rds_instance_count"            = "1"
      "az_zones"                      = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
      "min_capacity"                  = 0.5
      "max_capacity"                  = 1
      "log_types"                     = ["error", "general", "slowquery", "audit"]
      "publicly_accessible"           = true
      "add_scheduler_tag"             = true
      "whitelist_ips"                 = ["0.0.0.0/0"]
      "rds_max_connections"           = "50"
      "lambda_memory"                 = 256
      "retention_period"              = 30
      "provider-name"                 = "ORCID"
      "db_name"                       = "study_registry"
      "rds_password_secret_name"      = "nihrd-secret-dev-rds-aurora-mysql-rddi-study-management-admin-password"
      "stage_name"                    = "v1"
      "message_bus_topic"             = "nihrd-msk-dev-study-management-topic"
      "message_bus_bootstrap_servers" = "b-1.nihrdmskdevnsipcluster.z2kr4f.c2.kafka.eu-west-2.amazonaws.com"
      "apply_immediately"             = true
      "sleep_interval"                = "30"
      "ecs_cpu"                       = 512
      "ecs_memory"                    = 1024
      "bootstrap_servers"             = "b-1.nihrdmskdevnsipcluster.z2kr4f.c2.kafka.eu-west-2.amazonaws.com:9092,b-2.nihrdmskdevnsipcluster.z2kr4f.c2.kafka.eu-west-2.amazonaws.com:9092"
      "ecs_instance_count"            = "1"
      "wso2_service_audiences"        = "1t42eotpki9d6b5bl3n8all6ji"
      "wso2_service_issuer"           = "https://dev.id.nihr.ac.uk:443/oauth2/token"
      "wso2_service_token_endpoint"   = "https://dev.id.nihr.ac.uk/oauth2/oidcdiscovery"
    }
  }
}
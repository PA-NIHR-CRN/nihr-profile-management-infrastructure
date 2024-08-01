variable "env" {
  description = "environment name"
  type        = string

}
variable "name" {
  type = string
}

variable "system" {
  type = string
}

variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "ecs_subnets" {
  description = "list of subnets for ecs"
  type        = list(any)
}

variable "account" {
  description = "account name"
  type        = string
  default     = "nihrd"
}

variable "container_name" {
  description = "container"
  type        = string
}

variable "ecs_cpu" {
}

variable "ecs_memory" {
}

variable "image_url" {
  description = "container image url"
  type        = string
}

variable "rds_sg" {
  
}



#env
variable "bootstrap_servers" {
}
variable "message_bus_topic" {
}
variable "db_password" {
}
variable "sleep_interval" {
}
variable "instance_count" {
}
variable "rds_cluster_endpoint" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}
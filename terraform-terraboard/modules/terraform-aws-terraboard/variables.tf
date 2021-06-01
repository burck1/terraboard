variable "name" {
  type    = string
  default = "terraboard"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "terraboard_image" {
  type        = string
  default     = "camptocamp/terraboard:1.1.0"
  description = "https://hub.docker.com/r/camptocamp/terraboard/tags"
}

variable "terraboard_port" {
  type    = number
  default = 8080
}

variable "terraboard_log_level" {
  type    = string
  default = "info"

  validation {
    condition     = contains(["debug", "info", "warn", "error", "fatal", "panic"], var.terraboard_log_level)
    error_message = "Allowed values are \"debug\", \"info\", \"warn\", \"error\", \"fatal\", or \"panic\"."
  }
}

variable "terraboard_log_format" {
  type    = string
  default = "plain"

  validation {
    condition     = contains(["plain", "json"], var.terraboard_log_format)
    error_message = "Allowed values are \"plain\" or \"json\"."
  }
}

variable "state_bucket" {
  type = string
}

variable "state_key_prefix" {
  type    = string
  default = ""
}

variable "state_file_extension" {
  type        = string
  default     = ".tfstate"
  description = "File extension(s) of state files. Use a comma separated list."
}

variable "state_dynamodb_table" {
  type    = string
  default = ""
}

variable "assume_role_arn" {
  type = string
}

variable "assume_role_external_id" {
  type    = string
  default = ""
}

variable "postgres_image" {
  type        = string
  default     = "postgres:9.5"
  description = "https://hub.docker.com/_/postgres?tab=tags"
}

variable "container_insights" {
  type    = string
  default = "enabled"

  validation {
    condition     = contains(["enabled", "disabled"], var.container_insights)
    error_message = "Allowed values are \"enabled\" or \"disabled\"."
  }
}

variable "cpu" {
  type        = number
  default     = 1024
  description = "https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size"
}

variable "memory" {
  type        = number
  default     = 2048
  description = "https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size"
}

variable "cloudwatch_log_group_prefix" {
  type    = string
  default = "/terraboard"
}

variable "cloudwatch_log_group_retention" {
  type        = number
  default     = 30
  description = "retention in days"
}

variable "internal" {
  type    = bool
  default = true
}

variable "vpc_id" {
  type = string
}

variable "lb_subnets" {
  type = list(string)
}

variable "lb_ingress_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "ecs_subnets" {
  type = list(string)
}

variable "efs_subnets" {
  type = list(string)
}

variable "desired_tasks_count" {
  type    = number
  default = 1

  validation {
    condition     = var.desired_tasks_count == 0 || var.desired_tasks_count == 1
    error_message = "Allowed values are 0 or 1."
  }
}

variable "wait_for_steady_state" {
  type    = bool
  default = true
}

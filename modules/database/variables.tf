variable "vpc_id" {}
variable "private_subnets" { type = list(string) }

variable "vpc_cidr" { type = string }

variable "environment" { type = string }

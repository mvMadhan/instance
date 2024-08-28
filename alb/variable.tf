variable "ami_id" {
description = "this is amamzon ami_id"
type = string
}

variable "instance_type" {
description = "this is instance type"
type = string
}

variable "subnet_id" {
description = "this is amamzon subnet_id"
type = map(string)
}

variable "availability_zones" {
description = "this is amamzon availability_zones"
default = ["us-east-1a","us-east-1b"]
}


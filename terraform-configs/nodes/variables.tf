
variable "playground_vpc_id" {
  type        = string
  description = "The VPC ID created in vpc module"
}

variable "private_playground_subnet_us_east_1a_id" {
  type        = string
  description = "The subnet created in network module"
}

variable "aws_secure_group_id" {
  type        = list(string)
  default     = ["limited_access"]
  description = "The security group created in secure module"
}


variable "key-name" {
  default = "aws-at-pg-key"
}

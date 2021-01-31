# key variable
variable "key_name" {
  description = "ec2 key to connect"
  default = "ec2Key.pem"
}

# base_path variable
variable "base_path" {
  default = "/tmp/terraform_iac/"
}

variable "prefix" {
  description = "The prefix for the resource names. Name of VPC."
  default = "nt-vpc01"
}

variable "traffic_type" {
  default = "ALL"
  description = "https://www.terraform.io/docs/providers/aws/r/flow_log.html#traffic_type"
}

#AWS authentication variables
#variable "aws_access_key" {
#  type = string
#  description = "AWS Access Key"
#}

#variable "aws_secret_key" {
#  type = string
#  description = "AWS Secret Key"
#}

#variable "aws_key_pair" {
#  type = string
#  description = "AWS Key Pair"
#}

# Workaround for not being able to do interpolation in variable defaults
# https://github.com/hashicorp/terraform/issues/4084
locals {
  default_log_group_name = "${var.prefix}-flow-log"
}
variable "log_group_name" {
  default = ""
  description = "Will default to `default_log_group_name`"
}


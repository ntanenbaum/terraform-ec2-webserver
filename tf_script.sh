#!/bin/bash
# Simple Bash script to run terraform
#
terraform init

terraform plan -out=./terraform.out \
 |  tee terraform_plan.out

#terraform apply "./terraform.out" \
# | tee terraform_apply.out

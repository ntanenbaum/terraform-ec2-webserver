#!/bin/bash
# Simple Bash script to run terraform
#
echo "Initializing Terraform...."
terraform init

echo "Planning Terraform...."
terraform plan -out=./terraform.out \
 |  tee terraform_plan.out

echo "Applying Terraform...."
terraform apply "./terraform.out" \
 | tee terraform_apply.out


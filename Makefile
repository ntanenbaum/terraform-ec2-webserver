# ----------------------------------------------------------------------------
# Makefile for IaC
TF_DIR ?= "/tmp/terraform_iac1"
SHELL:=/bin/bash

tf-all: tf-dir tf-init tf-plan tf-apply

tf-dir:
	if [ ! -d "${TF_DIR}" ]; \
	then mkdir ${TF_DIR}; \
	fi

tf-bs:
	cd ./bootstrap \
          && ./bootstrap.sh

tf-ws-sel:
	terraform workspace select $(tf_ws)

tf-ws-new:
	terraform workspace new $(tf_ws_new)

tf-ws-list:
	terraform workspace list

tf-val:
	terraform validate

tf-get:
	terraform get -update

tf-init:
	terraform init

tf-plan: tf-init
	terraform plan -out=./terraform.out \
	|  tee terraform_plan.out

tf-apply: tf-plan
	terraform apply "./terraform.out" \
	| tee terraform_apply.out

tf-destroy:
	terraform destroy

tf-clean:
	rm -rf ./.terraform 
	rm -rf *.out

help:
	@grep -E '^[a-zA-Z_-]+:.*?## . *$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help


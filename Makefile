# ----------------------------------------------------------------------------
# Makefile for IaC
#
# Environment Variables
TF_DIR ?= "/tmp/terraform_iac1"

# Run all terraform commands
tf-all: tf-dir tf-init tf-plan tf-apply

# Run command to create terraform tmp directory
tf-dir:
	if [ ! -d "${TF_DIR}" ]; \
	then mkdir ${TF_DIR}; \
	fi

# Run command for bootstrap (testing)
tf-bs:
	cd ./bootstrap \
          && ./bootstrap.sh

# Run command to select a terraform workspace
tf-ws-sel:
	terraform workspace select $(tf_ws)

# Run command to create a new terraform workspace
tf-ws-new:
	terraform workspace new $(tf_ws_new)

# Run command to list terraform workspaces
tf-ws-list:
	terraform workspace list

# Run command to validate terraform
tf-val:
	terraform validate

# Run command to get terraform update
tf-get:
	terraform get -update

# Run command to init terraform
tf-init:
	terraform init

# Run command to plan terraform | includes init
tf-plan: tf-init
	terraform plan -out=./terraform.out \
	|  tee terraform_plan.out

# Run command to apply terraform | includes init and plan
tf-apply: tf-plan
	terraform apply "./terraform.out" \
	| tee terraform_apply.out

# Run command to destroy terraform
tf-destroy:
	terraform destroy

# Run command to clean terraform directories|files
tf-clean:
	rm -rf ./.terraform 
	rm -rf ./*.out
	rm -rf ./.terraform.lock.hcl

# Run command for help menu
help:
	@ echo
	@ echo '  Usage:'
	@ echo ''
	@ echo '    make <target>'
	@ echo ''
	@ echo '  Targets:'
	@ echo ''
	@ awk '/^#/{ comment = substr($$0,3) } comment && /^[a-zA-Z][a-zA-Z0-9_-]+ ?:/{ print "   ", $$1, comment }' $(MAKEFILE_LIST) | column -t -s ':' | sort
	@ echo ''
	@ echo '  Flags:'
	@ echo ''
	@ awk '/^#/{ comment = substr($$0,3) } comment && /^[a-zA-Z][a-zA-Z0-9_-]+ ?\?=/{ print "   ", $$1, $$2, comment }' $(MAKEFILE_LIST) | column -t -s '?=' | sort
	@ echo ''


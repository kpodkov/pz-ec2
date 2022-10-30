TF_IMAGE           :="hashicorp/terraform:1.3.2"
TF_LOG             :="ERROR"
PYTHON_IMAGE       :="python:3.9.12-slim-buster"
WORKDIR            := "pz-server/"
AWS_PROFILE        := "default"

plan: clean init
destroy: clean init
import: clean init
apply: plan

clean:
	@echo "========================"
	@echo " Cleaning tmp directory"
	@echo "========================"
	@docker run --rm -it \
	  --volume "${HOME}/.aws:/root/.aws" \
	  --volume "${PWD}:/infra" \
	  --workdir "/infra" \
	  "${PYTHON_IMAGE}" \
	  find . -type d -name ".terraform" -prune -exec rm -rf {} \;
	@docker run --rm -it \
	  --volume "${HOME}/.aws:/root/.aws" \
	  --volume "${PWD}:/infra" \
	  --workdir "/infra" \
	  "${PYTHON_IMAGE}" \
	  find . -type f -name "tfplan" -prune -exec rm -rf {} \;

init:
	@echo "================"
	@echo " Terraform Init"
	@echo "================"
	@docker run -it \
 	  --env AWS_PROFILE=${AWS_PROFILE} \
 	  --env TF_LOG="${TF_LOG}" \
 	  --volume "${HOME}/.aws:/root/.aws" \
 	  --volume "${HOME}/.azure:/root/.azure" \
 	  --volume "${PWD}:/infra" \
 	  --workdir "/infra/${WORKDIR}" \
 	  ${TF_IMAGE} \
 	  init

plan:
	@echo "================"
	@echo " Terraform Plan"
	@echo "================"
	@docker run -it \
 	  --env AWS_PROFILE=${AWS_PROFILE} \
   	  --env TF_LOG="${TF_LOG}" \
 	  --volume "${HOME}/.aws:/root/.aws" \
 	  --volume "${HOME}/.azure:/root/.azure" \
 	  --volume "${PWD}:/infra" \
 	  --workdir "/infra/${WORKDIR}" \
 	  ${TF_IMAGE} \
 	  plan -out=tfplan -input=false

destroy:
	@echo "================"
	@echo " Terraform Destroy"
	@echo "================"
	@docker run -it \
 	  --env AWS_PROFILE=${AWS_PROFILE} \
   	  --env TF_LOG="${TF_LOG}" \
 	  --volume "${HOME}/.aws:/root/.aws" \
 	  --volume "${HOME}/.azure:/root/.azure" \
 	  --volume "${PWD}:/infra" \
 	  --workdir "/infra/${WORKDIR}" \
 	  ${TF_IMAGE} \
 	  destroy -input=false


import:
	@echo "=================="
	@echo " Terraform Import"
	@echo "=================="
	@docker run -it \
 	  --env AWS_PROFILE=${AWS_PROFILE} \
   	  --env TF_LOG="${TF_LOG}" \
 	  --volume "${HOME}/.aws:/root/.aws" \
 	  --volume "${HOME}/.azure:/root/.azure" \
 	  --volume "${PWD}:/infra" \
 	  --workdir "/infra/${WORKDIR}" \
 	  ${TF_IMAGE} \
 	  import module.storage-integration.snowflake_storage_integration.default AWS_DATA_PRODUCTION

apply:
	@echo "================="
	@echo " Terraform Apply"
	@echo "================="
	@docker run -it \
 	  --env AWS_PROFILE=${AWS_PROFILE} \
 	  --env TF_LOG="${TF_LOG}" \
 	  --volume "${HOME}/.aws:/root/.aws" \
 	  --volume "${HOME}/.azure:/root/.azure" \
 	  --volume "${PWD}:/infra" \
 	  --workdir "/infra/${WORKDIR}" \
 	  ${TF_IMAGE} \
 	  apply -input=false tfplan
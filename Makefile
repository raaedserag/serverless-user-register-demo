#!make
include .env
export $(shell sed 's/=.*//' .env)

init:
	# aws s3api create-bucket --bucket $(TERRAFORM_BACKEND_S3_BUCKET) --region $(AWS_REGION)
	cd src; terraform init \
		-backend-config="bucket=$(TERRAFORM_BACKEND_S3_BUCKET)" \
		-backend-config="key=$(TF_VAR_namespace)-iac.tfstate"\
		-backend-config="region=$(AWS_REGION)" -reconfigure
plan:
	cd src; terraform plan 
deploy:
	cd src; terraform apply -auto-approve
destroy:
	cd src; terraform destroy -auto-approve
terraform:
	cd src; terraform $(filter-out $@,$(MAKECMDGOALS))
%:
	@:
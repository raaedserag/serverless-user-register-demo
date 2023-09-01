#!make
include .env
export $(shell sed 's/=.*//' .env)

init:
	echo "Creating S3 bucket for terraform state if not exists"
	aws s3api create-bucket \
		--bucket $(TERRAFORM_BACKEND_S3_BUCKET) \
		--create-bucket-configuration LocationConstraint=$(AWS_REGION) \
		|| true
	terraform init \
		-backend-config="bucket=$(TERRAFORM_BACKEND_S3_BUCKET)" \
		-backend-config="key=$(TF_VAR_namespace)-iac.tfstate"\
		-backend-config="region=$(AWS_REGION)"
plan:
	terraform plan 
deploy:
	terraform apply -auto-approve
destroy:
	terraform destroy -auto-approve
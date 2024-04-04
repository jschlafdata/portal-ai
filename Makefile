INITIAL_DIR := $(shell pwd)
AWS_PROFILE := [your project name!!]
AWS_START_URL := https://d-XXXXXXX.awsapps.com/start#/

define AWS_CONFIGURE_SSO
	export AWS_PROFILE=$(1) && export AWS_START_URL=$(2) && aws configure sso --profile $(1)
endef

deploy:
	# First phase: Initialization
	$(call AWS_CONFIGURE_SSO,$(AWS_PROFILE),$(AWS_START_URL)) && \
	poetry install && \
	poetry run python -m portal_ai.deployments.initialize && \
	cd portal_ai/terraform/aws_base && \
	terraform init && \
	terraform apply --target module.aws-key-pairs && \
	terraform apply --target module.networking

	# Pause for VPN initialization
	@echo "Please initialize your VPN connection now. Have you done this and wish to continue? [y/N]" && read ans && [ $${ans:-N} = y ]

	# Second phase: AWS Base Deployment
	$(call AWS_CONFIGURE_SSO,$(AWS_PROFILE),$(AWS_START_URL)) && \
	cd portal_ai/terraform/aws_base && \
	terraform init && \
	terraform apply && \
	cd $(INITIAL_DIR) && \
	poetry run python -m portal_ai.deployments.aggregate_configs


destroy:
	cd portal_ai/terraform/aws_base && \
	terraform destroy --target module.postgres_rds

	# Pause for VPN initialization
	@echo "Please turn off your VPN connection now. Have you done this and wish to continue? [y/N]" && read ans && [ $${ans:-N} = y ]
	
	cd portal_ai/terraform/aws_base && \
	terraform destroy && \
	cd ../../../ && \
	poetry run python -m portal_ai.destroy.destroy
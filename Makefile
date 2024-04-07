INITIAL_DIR := $(shell pwd)
AWS_PROFILE := analyticsedge-dev
AWS_START_URL := https://d-9067fc4734.awsapps.com/start#/
DOMAIN := analyticsedge.net
CLUSTER_NAME := k8s-dev.$(DOMAIN)
KOPS_STATE := s3://kops-dev.$(DOMAIN)

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
	
	# && \
	# ./portal_ai/scripts/kops/create_cluster.sh $(AWS_PROFILE)


destroy:
	$(call AWS_CONFIGURE_SSO,$(AWS_PROFILE),$(AWS_START_URL)) && \
	cd portal_ai/terraform/helm && \
	terraform destroy && \
	cd $(INITIAL_DIR) && \
	kops delete cluster --name $(CLUSTER_NAME) --state $(KOPS_STATE) --yes && \
	cd portal_ai/terraform/aws_base && \
	terraform destroy --target module.postgres_rds

	# Pause for VPN initialization
	@echo "Please turn off your VPN connection now. Have you done this and wish to continue? [y/N]" && read ans && [ $${ans:-N} = y ]
	
	cd portal_ai/terraform/aws_base && \
	terraform destroy && \
	cd ../../../ && \
	poetry run python -m portal_ai.destroy.destroy


refresh:
	# Pause for VPN check
	@echo "is your vpn running? [y/N]" && read ans && [ $${ans:-N} = y ]

	$(call AWS_CONFIGURE_SSO,$(AWS_PROFILE),$(AWS_START_URL)) && \
	kops export kubecfg --admin --name $(CLUSTER_NAME) --state $(KOPS_STATE)
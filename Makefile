# Default environment
# example execution: make init_global_configs ENV=stage
ENV ?= dev

setup:
	python3 -m tools.deployments.setup.key_gen

init_global_configs:
	python3 -m tools.templating.render_jinja_templates.render -e $(ENV) -m global_settings

init_aws_base: init_global_configs
	python3 -m tools.deployments.aws_base.remote_s3_buckets $(ENV) --create
	python3 -m tools.deployments.aws_base.tf_remote_states $(ENV)
	cd ./$(ENV)/terraform/aws_base && \
	terraform init && \
	terraform apply --target module.aws-key-pairs && \
	terraform apply --target module.networking && \
	terraform apply

init_k8s_configs: init_global_configs
	python3 -m tools.templating.render_jinja_templates.render -e $(ENV) -m aws_base_outputs
	python3 -m tools.templating.aggregate_yml_configs.generate_configs -e $(ENV) -m kops_base
	python3 -m tools.templating.render_jinja_templates.render -e $(ENV) -m kops_base_configs
	python3 -m tools.templating.k8s.generate_cluster_config $(ENV) --num_zones 1
	python3 -m tools.templating.aggregate_yml_configs.generate_configs -e $(ENV) -m helm_base
	python3 -m tools.templating.render_jinja_templates.render -e $(ENV) -m helm_base_configs
	python3 -m tools.templating.k8s.update_helm_values_files $(ENV)
	python3 -m tools.templating.aggregate_yml_configs.generate_configs -e $(ENV) -m mage_rbac
	python3 -m tools.templating.render_jinja_templates.render -e $(ENV) -m mage_rbac_configs


deploy_k8s:
	./tools/scripts/kops/create_cluster.sh $(ENV)
	cd ./$(ENV)/terraform/kops && \
	terraform init && \
	terraform apply
	python3 -m tools.deployments.helm.init_secret_backends dev



update_aws_base: init_global_configs
	python3 -m tools.deployments.aws_base.remote_s3_buckets $(ENV) --create
	python3 -m tools.deployments.aws_base.tf_remote_states $(ENV)
	cd ./$(ENV)/terraform/aws_base && \
	terraform init && \
	terraform apply


destroy_aws_base:
	cd ./$(ENV)/terraform/aws_base && \
	terraform destroy --target module.postgres_rds && \
	terraform destroy
	python3 -m tools.deployments.aws_base.remote_s3_buckets $(ENV) -d
	./tools/scripts/terraform/clear_terraform_cash.sh $(ENV) aws_base


destroy_cluster:
	./tools/scripts/kops/delete_cluster.sh $(ENV)	



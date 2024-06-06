---
sidebar_position: 1
slug: /
---

# Entire Repo Folder Structure

#### Use this as a reference to find concepts you want to learn more about or implement.
----------

```
portal-ai
    ├── Pipfile
    ├── Pipfile.lock
    ├── cluster_scaler
    │   ├── Dockerfile
    │   ├── deployment
    │   │   ├── deployment.yaml
    │   │   └── serviceaccount.yaml
    │   ├── gpu_testing
    │   │   └── pod_driver_example.yml
    │   ├── scale.sh
    │   └── scaling-config
    │       ├── g5-xl-nodes-us-west-2b.yaml
    │       ├── gpu-nodes copy.yaml
    │       ├── gpu-nodes.yaml
    │       └── p3-2xl-nodes.yaml
    ├── data_portal_react_django
    ├── docker_builds
    │   └── mageai
    │       ├── Dockerfile
    │       ├── entrypoint.sh
    │       └── requirements.txt
    ├── kubernetes_deployments
    │   ├── cert-manager.custom.yaml
    │   ├── helm
    │   │   ├── custom_charts
    │   │   │   ├── annas-api-chart
    │   │   │   ├── custom-bots
    │   │   │   │   ├── templates
    │   │   │   │   └── values.yaml
    │   │   │   ├── ingress-from-statefulset
    │   │   │   ├── multi-port-ingress
    │   │   │   ├── storage-chart
    │   │   │   └── vault-chart
    │   │   ├── mage
    │   │   ├── metabase
    │   │   ├── system-operators
    │   │   │   ├── cert-manager.values.yaml
    │   │   │   ├── cert-mng.values.yaml
    │   │   │   ├── external-dns.values.yaml
    │   │   │   ├── helm_deploy.sh
    │   │   │   ├── kube2iam.values.yaml
    │   │   │   ├── nginx-external.values.yaml
    │   │   │   └── nginx-internal.values.yaml
    │   ├── kops
    │   │   ├── cluster.yml
    │   │   ├── delete_cluster.sh
    │   │   ├── deploy.env
    │   │   ├── iam
    │   │   │   ├── iam-spec.yaml
    │   │   │   └── policies.yaml
    │   │   ├── launch_cluster.sh
    │   │   ├── rolling_update.sh
    │   │   └── update_cluster.sh
    │   ├── kops_commands
    │   │   └── cmds.yaml
    │   ├── kubectl
    │   │   ├── efs
    │   │   ├── if-docs
    │   │   ├── lets_encrypt
    │   │   ├── mage_configs
    │   │   └── vault
    │   ├── medusa
    │   ├── tools
    │   │   ├── build-kops-cluster-yml-config
    │   │   ├── kops_helpers
    │   │   ├── kub_gen_secret.sh
    │   │   ├── launch-cluster
    │   │   └── node-ip
    ├── setup
    │   ├── brew.yml
    │   ├── exec_commands.sh
    │   ├── git_ssh_config.sh
    │   ├── initial_setup_cmds.sh
    │   ├── pip_mac_setup.sh
    │   ├── requirements.txt
    │   ├── user_profile.yml
    │   ├── yml_py.py
    │   └── zshrc.yml
    ├── terraform
    │   ├── aws_org_create_accounts
    │   │   ├── main.tf
    │   └── development
    │       ├── databricks_wkspc_init
    │       │   ├── instance_profiles
    │       │   ├── workspace_global_ingestion_init
    │       │   └── workspace_pat
    │       ├── efs_tf
    │       ├── kubernetes
    │       │   ├── iam.tf
    │       │   └── vars.tf
    │       ├── main.tf
    │       ├── networking
    │       │   ├── data_portal_vpc
    │       │   ├── generated
    │       │   ├── openvpn_ec2
    │       │   └── vpn_gateway
    └── warehouse_auto_builder
        ├── global_modules
        │   ├── api_modules
        │   ├── auth_modules
        │   ├── dictionary_helpers.py
        │   ├── snowflake_metadata_library
        └── pipeline_schemas
```
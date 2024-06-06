---
sidebar_position: 1
---

# Overview (The Monolith)

## what is this.
The following documentation, code & guides are designed to create a monolithic deployment of everything necessary to build an enterprise grade cloud data system, with ready to scale self hosted LLM models, tight security policies and best practices & highly scalable data warehouse modules for metadata driven ETL architecture.

## how does it work.
This can be configured and deployed in any AWS region and account by changing metadata settings. It uses Mage AI as a central task orchestration tool to integrate across multiple cloud data warehouses and data lakes. Finally, it includes a custom built Django/React data portal that hosts documentation, data lineage, and live dashboards that provide visibility and test observability to the entire network.

* The entire system in the architecture diagram below can be deployed using two seperate commands, fully configured from a settings file where you input things like VPC and subnet CIDR blocks, alias for how you want things named, domains you own, etc.

![the monolith](/img/monolith/monolithic.png)


## deployment settings.

### example usage

* You can determine the amount of availability zones you deploy in & the size of your base k8s nodes.
* You decide how you want things named

```yaml title="kubernetes settings"
kops_ig_settings:
    image: ami-0080e1081b2c5aef6
    machineType: m5.large
    maxNodeSize: 3
```

```yaml title="dns settings"
aws_prefix: schlafdata
project_name: schlafdata

dns_zone: schlafdata
dns_domain:
    dev: schlafdata.cloud
    stage: schlaf-data.engineering
    prod: schlafdata.io
```

<details>
<summary>full global settings example file</summary>
<p>

```yaml title="global_settings.yaml"
deployment_metadata:
  aws_start_url: https://d-9267b09ec7.awsapps.com/start # sso login url
  aws_org_tfstate: tfstate.aicollab.manage #terraform state location for the management AWS account
  data_portal_name: One Portal for All
  aws_region: us-west-2

  git_admin_email: john@schlafdata.com
  git_admin_username: jschlafdata
  mage_git_repo_link: https://github.com/jschlafdata/mageai-schlafdata.git

  aws_prefix: schlafdata
  project_name: schlafdata

  dns_zone: schlafdata
  dns_domain:
    dev: schlafdata.cloud
    stage: schlaf-data.engineering
    prod: schlafdata.io
  dns_zone_id:
    dev: Z073043915ZSR6Y60ZWLQ
    stage: Z03862962LQBASQQRRS13
    prod: Z0874785XIHL4I3XGPM9
  
  aws_environments:
  - dev
  - stage
  - prod

  environment_prefixs:
    aws:
      dev: dev
      stage: stage
      prod: ''
    s3:
      dev: "-dev"
      stage: "-stage"
      prod: ''
    snowflake:
      dev: __dev
      stage: __stage
      prod: ''
    databricks:
      dev: __dev
      stage: __stage
      prod: ''

  # prefixes for s3 buckets and aws resources created.
  # example: kops state store: kops-[environment].[dns_domain]
  # terraform state store: tfstate-[environment].[dns_domain]

  kops_state_prefix: kops
  tfstate_prefix: tfstate
  k8s_prefix: k8s
  kops_iam_prefix: iam-http-dir
  k8s_terraform_prefix: k8s-tfstate

  kops_ig_settings:
    image: ami-0080e1081b2c5aef6
    machineType: m5.large
    maxNodeSize: 3

  aws_efs_driver: 602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/aws-efs-csi-driver

  ## configs for terraform modules.
  ovpn_configs:
    ovpn_config_directory: generated/ovpn-config
    ssh_private_key_file: id_ed25519_openvpn
    ssh_public_key_file: id_ed25519_openvpn.pub
    open_vpn_static_route_ip: "10.8.0.0/24"
    users:
    - john

  postgres_rds:
    db_user: rds_admin
    rds_app_name: app
  
  dev:
    vpc_cidr: 174.64.0.0/16
    public_subnets_cidr: 174.64.1.0/24
    private_subnets_cidr: 174.64.10.0/24

  stage:
    vpc_cidr: 174.65.0.0/16
    public_subnets_cidr: 174.65.1.0/24
    private_subnets_cidr: 174.65.10.0/24

  prod:
    vpc_cidr: 174.66.0.0/16
    public_subnets_cidr: 174.66.1.0/24
    private_subnets_cidr: 174.66.10.0/24
```
</p>
</details>

## high level process flow.

![the monolith](/img/monolith/monolithic_process.png)


## example terraform output file

* This is an example of cleaned and aggregated outputs from the deployment of the aws_base terraform module, which is then used to create the kubernetes cluster and various values for helm charts.

```yaml titel="terraform output"
nat_gateway_id: nat-0fb51d01dbdac6dfd
vpc_cidr_block: 174.64.0.0/16
vpc_id: vpc-0b0bcf9699c64913d
vpc_name: schlafdata-dev-vpc
rds_username: schlafdata_rds_admin
rds_instance_hostname: schlafdata-app-dev-db.cgczspewjg6d.us-west-2.rds.amazonaws.com:5432
efs_id: fs-09b3962c56074f973
public_subnets:
- availability_zone: us-west-2a
  subnet_id: subnet-031bbecab330e9229
  subnet_cidr: 174.64.1.0/27
private_subnets:
- availability_zone: us-west-2a
  subnet_id: subnet-04e1fa2d048c7226b
  subnet_cidr: 174.64.10.0/27
iam_policies:
  efs-csi-controller-sa: arn:aws:iam::406622241617:policy/efs-csi-controller-sa
  aws-lb-controller: arn:aws:iam::406622241617:policy/aws-lb-controller
  ecr: arn:aws:iam::406622241617:policy/ecr
  kops: arn:aws:iam::406622241617:policy/kops
  external-dns: arn:aws:iam::406622241617:policy/external-dns
```

## ur gunna need to know this stuff.

The following tools and languages are leveraged `heavily` in this project.

* `terraform`
* `kubernetes (k8s)`
* `helm`
* `python`
* `bash`
* `jinja`
* `kops`
* `django`
* `react`
* `mage ai`
* `snowflake`
* `databricks`
* `postgres`

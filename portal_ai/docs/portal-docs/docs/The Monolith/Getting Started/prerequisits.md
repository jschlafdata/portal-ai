---
sidebar_position: 1
---

# Privileges

* You must have god powers in AWS.
* At least one active AWS account.
* At least one hosted domain and zone in Route 53
* AWS SSO authentication activated with a start url

## Project Overview

This project is set up to be able to create, build, and destroy all resources in an AWS account. I have it set up to be able to build resources across multiple aws environments (dev, stage, prod) respectively.

The main idea with this project is to reflect a true enterprise grade build, keeping in mind security best practices and streamlined development using infrastructure as code.

:::note
While this is intended to reflect real world set ups, it is not entirely perfect. Since I am running this as a personal project with my own money, I never build resources in more than one AWS account at a time. There are some caveats here where I am keeping in mind a semi-tight budget. 

e.g. - only using one availability zone for kubernetes.
    (The repo is structured to support many, should you choose.)
:::


## General Configurations

In the root of the repository, there is a file called `global_settings.yaml`.

These settings create prefixes, remote storage buckets, and define resources that would not make sense to automate or require some kind of existing resource in AWS.

:::important
Prefixes are used to create standardized naming conventions across s3 buckets, k8s resources, domain names, application names etc.
:::

```yaml title="global_settings.yaml"
deployment_metadata:
  aws_prefix: schlafdata
  project_name: schlafdata
  dns_zone: schlafdata
  dns_domain:
    dev: schlafdata.cloud
    stage: schlafdata.tools
    prod: schlafdata.io
  dns_zone_id:
    dev: Z0874785XIHL4I3XGPM9
    stage: Z0711371143C8LIXMFAPD
    prod: Z0874785XIHL4I3XGPM9
  vpn_internal_network_ip: 10.8.0.0/24
  aws_environments:
  - dev
  - stage
  - prod
  aws_start_url: https://d-9267b09ec7.awsapps.com/start
  aws_org_tfstate: tfstate.aicollab.manage
  data_portal_name: One Portal for All

  # prefixes for s3 buckets and aws resources created.
  # example: kops state store: kops-[environment].[dns_domain]
  # terraform state store: tfstate-[environment].[dns_domain]

  kops_state_prefix: kops
  tfstate_prefix: tfstate
  k8s_prefix: k8s
  kops_iam_prefix: iam-http-dir
  k8s_terraform_prefix: k8s-tfstate
  git_admin_email: john@schlafdata.com
  git_admin_username: jschlafdata
```


# AWS Resource Naming Conventions

This document outlines standardized naming conventions for AWS resources, utilizing prefixes to ensure consistency across different environments.

## Prefixes Overview

- **Kops State Store Prefix**: `kops`
- **Terraform State Store Prefix**: `tfstate`
- **Kubernetes (k8s) Prefix**: `k8s`
- **Kops IAM Prefix**: `iam-http-dir`
- **K8s Terraform Prefix**: `k8s-tfstate`

## Examples

- Kops State Store
    * `kops-[environment].[dns_domain]`
- Terraform State Store
    * `tfstate-[environment].[dns_domain]`
- K8s-Terraform State Store
    * `k8s-tfstate-[environment].[dns_domain]`
- Kops Iam S3 Bucket:
    * `iam-http-dir-[environment].[dns_domain]`


## S3 Backends Naming Conventions

S3 backends use the defined prefixes to create environment-specific resource names.

### Kops

| Environment | Bucket Name                 |
|-------------|-----------------------------|
| Dev         | `kops-dev.schlafdata.cloud` |
| Stage       | `kops-stage.schlafdata.tools` |
| Prod        | `kops.schlafdata.io`        |

### Terraform

| Environment | Bucket Name                     |
|-------------|---------------------------------|
| Dev         | `tfstate-dev.schlafdata.cloud`  |
| Stage       | `tfstate-stage.schlafdata.tools`|
| Prod        | `tfstate.schlafdata.io`         |

### Kops IAM

| Environment | Bucket Name                        |
|-------------|------------------------------------|
| Dev         | `iam-http-dir-dev.schlafdata.cloud`|
| Stage       | `iam-http-dir-stage.schlafdata.tools`|
| Prod        | `iam-http-dir.schlafdata.io`       |

### Kubernetes Terraform

| Environment | Bucket Name                         |
|-------------|-------------------------------------|
| Dev         | `k8s-tfstate-dev.schlafdata.cloud`  |
| Stage       | `k8s-tfstate-stage.schlafdata.tools`|
| Prod        | `k8s-tfstate.schlafdata.io`         |


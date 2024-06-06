
# Postgres RDS and EFS

This Terraform module provisions various AWS resources including an RDS instance, a DB subnet group, security groups, and an Elastic File System (EFS). It is designed to support applications by providing database services, file storage, and network security configurations.

:::note
The `postgres RDS` database is created to use as a backend application database. I use it for MageAI (task orchestration tool), The Django-React data portal website, Metabase (dashboard tool), and others.

The `Elastic File Store` is used for MageAI system and data storage, as well as various kubernetes pod applications like self hosted LLM models.
:::


## Elastic File Store

I like to use EFS as a backend for mageAI and certain kubernetes resources because it allows for shared storage and access across pods.

It also persists, even if you destroy, delete, or migrate a pod to a new location -- the storage persists and is not lost. I do not use it as storage for any sensitive information within these applications, however.

* `Scalability`: EFS automatically scales with the amount of stored data, from a few MBs to petabytes without needing to provision storage in advance. This makes it an excellent choice for applications with fluctuating storage requirements.

* `Simplicity`: EFS is easy to use, allowing you to create and configure file systems quickly without managing complex storage infrastructure. It integrates seamlessly with AWS services, making it straightforward to add scalable file storage to your cloud applications.

* `Shared File Access`: EFS supports the Network File System (NFS) protocol, allowing multiple EC2 instances to access the file system simultaneously. This is particularly useful for applications that require shared access to files, such as web servers in a load-balanced environment or collaborative applications where multiple users need to access and edit documents at the same time.


:::important
This module leverages outputs from the [vpc & subnet module](../Networking/vpc.md) to create security groups that allow ingress from within the existing VPC only. As these are primarily application databases, most network activity and requests will come from applications running inside other private subnets within the same VPC.
:::


## Providers

- **AWS**: The module uses the AWS provider to provision resources in the specified AWS region.

## Resources

### `aws_db_subnet_group`

- **Description**: Creates a DB subnet group for the RDS instance, ensuring it's placed within the specified subnets for network isolation.
- **Name**: Constructed using application name and environment, following the pattern `<app_name>-<app_environment>-rds-subnet-group`.
- **Subnets**: Uses private subnet IDs provided through `var.private_subnet_ids`.
- **Tags**: Includes an `Environment` tag with the application environment.

### `aws_security_group` for RDS

- **Description**: Defines a security group for the RDS instance to control access.
- **Name**: Constructed using application name and environment, following the pattern `<app_name>-<app_environment>-rds-sg`.
- **Ingress Rules**:
  - Allows internal traffic within the security group.
  - Allows TCP traffic on port 443 and ports 5423 to 5432 for database connections.
  - Allows HTTP traffic on port 80.
- **Egress Rules**: Allows all outbound traffic.

### `aws_db_instance`

- **Description**: Provisions an RDS instance for database services.
- **Identifier**: Uses application name and environment for naming, following the pattern `<app_name>-<app_environment>-db`.
- **Configuration**: Includes settings for storage, database engine, instance size, and credentials.
- **Network**: Associates with the created DB subnet group and security group.

### `aws_efs_file_system`

- **Description**: Creates an Elastic File System for scalable file storage.
- **Configuration**: Configured for encryption, performance, and throughput.
- **Tags**: Includes `Name` and `Environment` tags.

### `aws_security_group` for EFS

- **Description**: Defines a security group for the EFS mount targets to control access.
- **Name**: Named after the application and EFS, following the pattern `<app_name>-efs-sg`.
- **Ingress Rules**: Dynamically allows TCP traffic on port 2049 from private subnets.

### `aws_efs_mount_target`

- **Description**: Creates a mount target for the EFS in a specified subnet, allowing EC2 instances to access the file system.
- **Configuration**: Associates with the first private subnet ID and uses the EFS security group.

## Variables

This module requires several variables to be defined for customization and proper resource allocation:

- `aws_region`: The AWS region where resources will be provisioned.
- `app_name`: Name of the application, used in resource naming.
- `app_environment`: Deployment environment (e.g., `dev`, `prod`), used in resource naming and tagging.
- `private_subnet_ids`: List of private subnet IDs for database and file system placement.
- `vpc_id`: VPC ID where the resources will be created.
- `cidr_block`: CIDR block for configuring access in security group rules.
- `database_user`: Username for the database instance.
- `app_db_password`: Password for the database instance.
- `private_subnet_cidrs`: CIDR blocks of the private subnets, used for EFS mount target security group rules.

## Usage

To use this module, define the required variables in your Terraform configuration and include the module with its source path. Ensure you have configured your AWS provider and any necessary authentication.

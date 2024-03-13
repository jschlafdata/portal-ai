terraform {
        backend "s3" {
            bucket = "tfstate-dev.schlafdata.cloud"
            key = "snowflake"
            region = "us-west-2"
            encrypt = true
            }
        }
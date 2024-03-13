terraform {
        backend "s3" {
            bucket = "tfstate-dev.schlafdata.cloud"
            key = "kops"
            region = "us-west-2"
            encrypt = true
            }
        }
terraform {
        backend "s3" {
            bucket = "tfstate-dev.schlafdata.cloud"
            key = "aws_base"
            region = "us-west-2"
            encrypt = true
            }
        }
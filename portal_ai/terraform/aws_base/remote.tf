terraform {
            backend "s3" {
                bucket = "tfstate-dev.analyticsedge.cloud"
                key = "aws_base"
                region = "us-east-1"
                encrypt = true
                }
            }
terraform {
            backend "s3" {
                bucket = "tfstate-dev.analyticsedge.net"
                key = "aws_base"
                region = "us-east-1"
                encrypt = true
                }
            }
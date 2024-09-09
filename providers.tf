terraform {
    required_providers {
        aws={
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
    cloud { 
        organization = "Bootcamp-terraform--" 
        workspaces { 
            name = "terraform-workflow-github" 
        } 
    }    
}

provider "aws" {
    region = "us-east-1"
    ##profile = "master"
}

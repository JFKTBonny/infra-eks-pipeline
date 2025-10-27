terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "bonny-terraform-state-prod"      # S3 bucket for state
    key            = "eks/terraform.tfstate"        # Path in the bucket
    region         = "us-east-1"                    # AWS region
    encrypt        = true                            # Encrypt state at rest
    # dynamodb_table = "terraform-locks"             # Optional: table for locking
  }
}
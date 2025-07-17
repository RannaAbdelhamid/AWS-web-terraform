terraform {
  backend "s3" {
    bucket = "backend-project1-bucket"
    key    = "backend.tfstate"
    region = "us-east-1"
    dynamodb_table = "lockstate-project" 
  }
}



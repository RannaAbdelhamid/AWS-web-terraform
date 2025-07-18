# AWS Multi-Tier Web Application with Terraform

This project builds a multi-tier architecture on AWS to host a simple web application using Terraform.
It demonstrates best practices for organizing a cloud environment with public/private subnets, security groups, NAT, Nginx reverse proxy, and Application Load Balancers (ALB).

   <img width="678" height="406" alt="arch" src="https://github.com/user-attachments/assets/f0bcc4b3-23bf-4fbd-ab1d-380175318999" />


## Key AWS Resources

- VPC: With 2 Public and 2 Private Subnets across 2 AZs

- Internet Gateway: For Public Subnets

- NAT Gateway: For Private Subnets internet access

- Route Tables: Public and Private routing properly configured

- Security Groups: Secure traffic flow between layers

- EC2 Instances:

   - Public Subnets: Nginx Reverse Proxy Servers

  - Private Subnets: Flask Web Application Servers (port 5000)

- Application Load Balancers:

  - Public ALB (routes to Nginx)

  - Internal ALB (routes from Nginx to Backend)

- S3 Bucket: (Optional) For static backend storage


## Technologies Used
- AWS VPC / EC2 / ALB / S3 / NAT

- Terraform (Infrastructure as Code)

- Amazon Linux 2023

- Nginx (Reverse Proxy)

- Python Flask (Backend)

## Terraform Project Structure

```
.
├── modules/         # Each module contain its main, variable and output files
│   ├── nginx-instance/
│   ├── backend-instance/
│   ├── public-subnet/
│   └── private-subnet/
├── main.tf           # Main code
├── outputs.tf        # Outputs of the code (DNS URL)
├── variables.tf      
├── providor.tf       # AWS provider
├── backend.tf        # Configures Terraform remote backend in S3
├── README.md

```

## Terraform Remote State Configuration
Terraform uses an S3 bucket to store the remote state file to ensure:

 - State consistency in collaborative environments

 - Separation of infrastructure management from local machines

```
terraform {
  backend "s3" {
    bucket = "backend-project1-bucket"
    key    = "backend.tfstate"
    region = "us-east-1"
    dynamodb_table = "lockstate-project" 
  }
}
```

<img width="1887" height="545" alt="devbuck" src="https://github.com/user-attachments/assets/82847ba2-070e-4c72-bf18-399ac95ef304" />

## How to Deploy

1️⃣ Initialize Terraform
```
terraform init
```

2️⃣ Validate the Configuration
```
terraform validate
```

3️⃣ Deploy the Infrastructure
```
terraform apply
```

## Testing the Deployment
1. Access the Public ALB DNS URL.

2. The request will be routed to:

   - Public EC2 (Nginx Reverse Proxy)

   - Internal ALB

   - Private EC2 (Flask Backend)

## Result
 - When using Public DNS you will get the content of the private machine in the private subnet
 - All Ips of the machines will be saved in the EC2-IPs.txt file

<img width="736" height="203" alt="screen1" src="https://github.com/user-attachments/assets/4963177c-0176-490b-bc8e-f25d37df7377" />


<img width="671" height="132" alt="screen2" src="https://github.com/user-attachments/assets/3885728e-fb8e-4828-ab78-397e21814996" />

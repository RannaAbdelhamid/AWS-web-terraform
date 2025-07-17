# AWS Multi-Tier Web Application with Terraform

This project builds a multi-tier architecture on AWS to host a simple web application using Terraform.
It demonstrates best practices for organizing a cloud environment with public/private subnets, security groups, NAT, Nginx reverse proxy, and Application Load Balancers (ALB).

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

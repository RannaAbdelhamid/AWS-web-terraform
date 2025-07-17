# Back end S3 bucket
resource "aws_s3_bucket" "backend" {
  bucket = "backend-project1-bucket"
}

#vpc
resource "aws_vpc" "project-vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "project-vpc"
  }
}

# public Subnet 1
module "public-subnet-1" {
    source = "./public-subnet"
    vpc = aws_vpc.project-vpc.id
    cidr = "10.0.0.0/24"
    name = "public-subnet-1"
    AZ = "us-east-1a"
}

# public Subnet 2
module "public-subnet-2" {
    source = "./public-subnet"
    vpc = aws_vpc.project-vpc.id
    cidr = "10.0.2.0/24"
    name = "public-subnet-2"
    AZ = "us-east-1b"
}

# private subnet 1
module "private-subnet-1" {
    source = "./private-subnet"
    vpc = aws_vpc.project-vpc.id
    cidr = "10.0.1.0/24"
    name = "private-subnet-1"
    Az = "us-east-1a"
}

# private subnet 2
module "private-subnet-2" {
    source = "./private-subnet"
    vpc = aws_vpc.project-vpc.id
    cidr = "10.0.3.0/24"
    name = "private-subnet-2"
    Az = "us-east-1b"
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.project-vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}


# NAT Gateway
resource "aws_nat_gateway" "gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = module.public-subnet-1.id

  tags = {
    Name = "gw-NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# Public Routing table
resource "aws_route_table" "route-table-pub" {
  vpc_id = aws_vpc.project-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "route-table-public"
  }
}

# Public association
resource "aws_route_table_association" "first" {
  subnet_id      = module.public-subnet-1.id
  route_table_id = aws_route_table.route-table-pub.id
}

# Public association 2
resource "aws_route_table_association" "second" {
  subnet_id      = module.public-subnet-2.id
  route_table_id = aws_route_table.route-table-pub.id
}

# Private Route table
resource "aws_route_table" "route-table-private" {
  vpc_id = aws_vpc.project-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gateway.id
  }

  tags = {
    Name = "Route-table-private"
  }
}

# private association
resource "aws_route_table_association" "association-priv1" {
  subnet_id      = module.private-subnet-1.id
  route_table_id = aws_route_table.route-table-private.id
}

# private association 2
resource "aws_route_table_association" "association-priv2" {
  subnet_id      = module.private-subnet-2.id
  route_table_id = aws_route_table.route-table-private.id
}

# security group
resource "aws_security_group" "project-sg" {
  name        = "project-sg"
  description = "Project security group to allow ssh and http"
  vpc_id      = aws_vpc.project-vpc.id

  tags = {
    Name = "project-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-ssh" {
  security_group_id = aws_security_group.project-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow-http" {
  security_group_id = aws_security_group.project-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow-5000" {
  security_group_id = aws_security_group.project-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.project-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# ami in data source 
data "aws_ami" "amz-ami" {
  most_recent = true
  owners      = ["amazon"]
   filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
   filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}

# ec2 in public subnet 1
module "nginx1" {
  source = "./nginx-instance"
  name = "nginx-pub1"
  subnet_id = module.public-subnet-1.id
  ami = data.aws_ami.amz-ami.id
  sec-g = [aws_security_group.project-sg.id]
}

# ec2 in public subnet 2
module "nginx2" {
  source = "./nginx-instance"
  name = "nginx-pub2"
  subnet_id = module.public-subnet-2.id
  ami = data.aws_ami.amz-ami.id
  sec-g = [aws_security_group.project-sg.id]
}

# ec2 in private subnet 1
module "backend1" {
  source = "./backend-instance"
  name = "backend-priv1"
  subnet_id = module.private-subnet-1.id
  ami = data.aws_ami.amz-ami.id
  sec-g = [aws_security_group.project-sg.id]
  bastion_host = module.nginx1.public_ip
  
}

# ec2 in private subnet 2
module "backend2" {
  source = "./backend-instance"
  name = "backend-priv2"
  subnet_id = module.private-subnet-2.id
  ami = data.aws_ami.amz-ami.id
  sec-g = [aws_security_group.project-sg.id]
  bastion_host = module.nginx2.public_ip
}

# Public Load Balancer
resource "aws_lb" "public_alb" {
  name               = "public-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [module.public-subnet-1.id, module.public-subnet-2.id]
  security_groups    = [aws_security_group.project-sg.id]
}

# Internal Load Balancer
resource "aws_lb" "internal_alb" {
  name               = "int-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = [module.private-subnet-1.id, module.private-subnet-2.id]
  security_groups    = [aws_security_group.project-sg.id]
}

# Public ALB Listener
resource "aws_lb_listener" "public_listener" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

# Internal ALB Listener
resource "aws_lb_listener" "internal_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 5000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

# Public nginx target group
resource "aws_lb_target_group" "nginx_tg" {
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.project-vpc.id
}

# Internal backend flask target group
resource "aws_lb_target_group" "backend_tg" {
  port        = 5000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.project-vpc.id
}

# Attachment
resource "aws_lb_target_group_attachment" "nginx1" {
  target_group_arn = aws_lb_target_group.nginx_tg.arn
  target_id        = module.nginx1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "nginx2" {
  target_group_arn = aws_lb_target_group.nginx_tg.arn
  target_id        = module.nginx2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "backend1" {
  target_group_arn = aws_lb_target_group.backend_tg.arn
  target_id        = module.backend1.id
  port             = 5000
}

resource "aws_lb_target_group_attachment" "backend2" {
  target_group_arn = aws_lb_target_group.backend_tg.arn
  target_id        = module.backend2.id
  port             = 5000
}

# Public Subnet
resource "aws_subnet" "pub-subnet" {
  vpc_id     = var.vpc
  cidr_block = var.cidr
  map_public_ip_on_launch = true
  availability_zone = var.AZ

  tags = {
    Name = var.name
  }
}

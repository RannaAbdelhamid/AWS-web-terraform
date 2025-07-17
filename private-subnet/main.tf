# Public Subnet
resource "aws_subnet" "pub-subnet" {
  vpc_id     = var.vpc
  cidr_block = var.cidr
  availability_zone = var.Az

  tags = {
    Name = var.name
  }
}

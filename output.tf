output "vpc_id" {
    value = aws_vpc.project-vpc.id
}

output "public_dns" {
    value = aws_lb.public_alb.dns_name
}

output "internal_dns" {
    value = aws_lb.internal_alb.dns_name
}
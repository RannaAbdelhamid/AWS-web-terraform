/*output "public_ip" {
    value = aws_instance.nginx_a.public_ip
}*/

output "private_ip" {
    value = aws_instance.backend.private_ip
}

output "id" {
    value = aws_instance.backend.id
  
}
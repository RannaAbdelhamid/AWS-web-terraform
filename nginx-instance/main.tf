resource "aws_instance" "nginx" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.sec-g
  associate_public_ip_address = true
  key_name                    = "project"

  tags = {
    Name = var.name
  }

  provisioner "remote-exec" {
    inline = [ 
      "sudo yum update -y",
      "sudo amazon-linux-extras enable nginx1",
      "sudo yum install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "echo '<h1>NGINX Instance A (Subnet A)</h1>' | sudo tee /usr/share/nginx/html/index.html",
      "echo 'server { listen 80; server_name _; location / { proxy_pass http://internal-int-alb-1991368972.us-east-1.elb.amazonaws.com:5000; proxy_set_header Host \\$host; proxy_set_header X-Real-IP \\$remote_addr; proxy_set_header X-Forwarded-For \\$proxy_add_x_forwarded_for; } }' | sudo tee /etc/nginx/conf.d/reverse-proxy.conf",
      "sudo systemctl restart nginx"
    ]
    
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("./../project.pem")
      host = self.public_ip
    }
    
  }

  provisioner "local-exec" {
    command = "echo The ${var.name} Public ip is ${self.public_ip}, and its Private ip is ${self.private_ip} >> ./EC2-IPs.txt"
    
  }
}
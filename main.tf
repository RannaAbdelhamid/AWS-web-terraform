resource "aws_instance" "backend" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.sec-g
  associate_public_ip_address = false
  key_name                    = "project"

  tags = {
    Name = var.name
  }


  provisioner "file" {
    source      = "./app.py"
    destination = "/home/ec2-user/app.py"

    connection {
      type                = "ssh"
      user                = "ec2-user"
      private_key         = file("./../project.pem")
      bastion_host        = var.bastion_host
      bastion_user        = "ec2-user"
      bastion_private_key = file("./../project.pem")
      host                = self.private_ip
    }
  }

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "ec2-user"
      private_key         = file("./../project.pem")
      bastion_host        = var.bastion_host
      bastion_user        = "ec2-user"
      bastion_private_key = file("./../project.pem")
      host                = self.private_ip
    }

    inline = [
      "sudo yum update -y",
      "sudo yum install -y python3",
      "sudo yum install -y python3-pip",
      "pip3 install flask",
      #"cd /home/ec2-user/backend",
      "nohup python3 app.py &"
    ]
  }
  provisioner "local-exec" {
    command = "echo The ${var.name} Private ip is ${self.private_ip} >> ./EC2-IPs.txt"
  }
}

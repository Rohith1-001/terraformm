resource "aws_instance" "terraform" {
  ami                    = "ami-081b0a6eac00b4f53"
  instance_type          = var.environment == "prod" ? "t3.small" : "t3.micro"  #condition here it was like if it is prod then it will take t3.small if not it will take t3.micro
  vpc_security_group_ids = [aws_security_group.allow_ssh_terraform.id]

  tags = {
    Name = "terraform-ec2"
  }
}

resource "aws_security_group" "allow_ssh_terraform" {
  name        = "allow_ssh"
  description = "Allow port number 22 for SSH access"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

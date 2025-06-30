provider "aws" {
  region = "us-east-1"  # or your region
}

data "aws_key_pair" "existing_key" {
  key_name = "vockey"
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-flask-sg"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "flask_ec2" {
  ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = data.aws_key_pair.existing_key.key_name
  security_groups = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "FlaskCachingLab"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y python3 git
              python3 -m pip install --upgrade pip
              pip3 install flask
              mkdir /home/ec2-user/app
              chown ec2-user:ec2-user /home/ec2-user/app
              EOF
}

output "ec2_public_ip" {
  value = aws_instance.flask_ec2.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/vockey.pem ec2-user@${aws_instance.flask_ec2.public_ip}"
}

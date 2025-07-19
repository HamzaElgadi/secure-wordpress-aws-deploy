terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.12.2"
}

provider "aws" {
  region = "eu-north-1"
}

variable "instance_type" {
  description = "Type d'instance EC2"
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nom de la paire de clés SSH"
  default     = "key-pair"
}

locals {
  ubuntu_ami_id = "ami-07ec1c55c9e5e1386"
}

resource "aws_security_group" "wordpress_site" {
  name        = "wordpress_site"
  description = "Allow SSH, HTTP, HTTPS"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All traffic out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress_site"
  }
}

resource "aws_instance" "wordpress_ec2" {
  ami                    = local.ubuntu_ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.wordpress_site.id]

  tags = {
    Name = "Ubuntu-WordPress-Server"
  }
}

output "instance_public_ip" {
  description = "Adresse IP publique de l'instance EC2"
  value       = aws_instance.wordpress_ec2.public_ip
}

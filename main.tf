terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "5.17.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}

provider "aws" {

region = "us-east-1"
}

provider "github" {
  token = file("github_token")
}

resource "aws_iam_role" "jenkins_server" {
  name = "jenkins-server"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess", "arn:aws:iam::aws:policy/AmazonEC2FullAccess","arn:aws:iam::aws:policy/AmazonS3FullAccess"]


}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-server-profile"
  role = aws_iam_role.jenkins_server.name
}


resource "aws_instance" "jenkins_ec2" {
  ami           = var.myami
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.tf-jenkins-sec-gr.id]
  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name
  tags = {
    Name = var.tag
  }
  user_data = file("jenkins.sh")
}

resource "aws_security_group" "tf-jenkins-sec-gr" {
  name        = "${var.jenkins-sg}-${var.user}"
  tags = {
    name = var.jenkins-sg
  }
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
    }
}
output "jenkins-server" {
  value = "http://${aws_instance.jenkins_ec2.public_dns}:8080"
}

resource "aws_s3_bucket" "jenkinsbucket" {
  bucket = "jenkins-project-oguzhan"

  tags = {
    Name        = "Jenkins-project"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.jenkinsbucket.id
  acl    = "private"
}

resource "github_repository" "git_repo1" {
  name        = "jenkins-project"

  visibility = "public"
  auto_init = true
}


#!/bin/bash
# #Install git and Jenkins in your EC2 instance
sudo yum update -y
hostnamectl set-hostname jenkins-server
sudo yum install git -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum upgrade
sudo amazon-linux-extras install java-openjdk11 -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo usermod -a -G docker jenkins

# Install Docker
sudo yum install docker -y
sudo service docker start
sudo systemctl enable Docker
sudo usermod -a -G docker ec2-user

# Install Terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

#Install Ansible
sudo amazon-linux-extras install ansible2 -y

#Install boto3
pip install pip --upgrade
pip install boto3

#uninstall aws clie version 1
rm -rf /bin/aws
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install


provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "ec2_sg_allow_all_traffic" {
  name        = "ec2-sg-allowall-traffic"
  description = "Allow all inbound and outbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allows all inbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {
  ami           = "ami-0e593d2b811299b15"
  instance_type = "t2.medium"  # Updated instance type
  key_name      = "linux-k8s"   # Ensure this key pair exists
  subnet_id     = "subnet-09ccc23a13c2684b8"

  # Reference the new security group by its ID
  vpc_security_group_ids = [aws_security_group.ec2_sg_allow_all_traffic.id]

  tags = {
    Name = "Jenkins"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y yum-utils shadow-utils
              yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
              yum -y install terraform
              yum install java-17-amazon-corretto -y
              amazon-linux-extras install epel -y
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              yum install jenkins -y
              systemctl start jenkins
              systemctl enable jenkins
              yum install git -y
              yum install docker -y
              systemctl start docker
              systemctl enable docker
              usermod -aG docker jenkins
              systemctl restart jenkins
              curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.15/2023-01-11/bin/linux/amd64/kubectl
              chmod +x ./kubectl
              mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl
              export PATH=$HOME/bin:$PATH
              EOF
}

output "instance_id" {
  value = aws_instance.jenkins.id
}

output "public_ip" {
  value = aws_instance.jenkins.public_ip
}

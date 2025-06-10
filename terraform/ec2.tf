/*
1. ec2 instance resource
2. new security group
    - 22 (ssh)
    - 443 (https)
    - 3000 (nodejs) // ip:3000
*/

resource "aws_instance" "tf_ec2_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  associate_public_ip_address = true
  key_name = "terraform-ec2"
  vpc_security_group_ids = [module.ec2_sg.security_group_id]

  depends_on = [ aws_s3_bucket.tf_s3_bucket ]
  user_data = <<-EOF
    #!/bin/bash

    # Git clone
    git clone https://github.com/Abrahamosaz/nodejs-mysql.git /home/ubuntu/nodejs-mysql
    cd /home/ubuntu/nodejs-mysql

    # install nodejs
    sudo apt update -y
    sudo apt install -y nodejs npm

    # edit env vars
    echo "DB_HOST=${local.rds_enpoint}" | sudo tee .env
    echo "DB_USER=${aws_db_instance.tf_rds_instance.username}" | sudo tee -a .env
    echo "DB_PASSWORD=${aws_db_instance.tf_rds_instance.password}" | sudo tee -a .env
    echo "DB_NAME=${aws_db_instance.tf_rds_instance.db_name}" | sudo tee -a .env
    echo "PORT=3000" | sudo tee -a .env

    # start server
    npm install
  EOF

  user_data_replace_on_change = true

  tags = {
    Name = var.app_name
  }
}



locals {
  ec2_cidr_blocks = ["102.89.83.23/32", "0.0.0.0/0"]
}



module "ec2_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name = "Nodejs Server SG"
  description = "Security group for ec2 instance with https and ssh open within VPC"
  vpc_id = var.vpc_id

  egress_rules        = ["all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      description = "Nodejs application port"
      cidr_blocks = local.ec2_cidr_blocks[1]
    },
    {
      rule = "https-443-tcp"
      cidr_blocks = local.ec2_cidr_blocks[1]
    },
    {
      rule = "ssh-tcp"
      cidr_blocks = local.ec2_cidr_blocks[0]
    },
  ]
}

#output
output "ec2_public_ip" {
    value = "ssh -i ~/.ssh/terraform-ec2.pem ubuntu@${aws_instance.tf_ec2_instance.public_ip}"
}

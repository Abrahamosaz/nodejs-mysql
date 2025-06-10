/*
1. rds instance
2. security group
    - 3306
        - security-grp => tf_ec2_sg
        - cidr_block => ["local ip"]
3. outputs
*/


data "aws_vpc" "default" {
  default = true
}

resource "aws_db_instance" "tf_rds_instance" {
  allocated_storage    = 10
  db_name              = "node_mysql"
  identifier           = "nodejs-mysql-database"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.mysql_username
  password             = var.mysql_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = true
  vpc_security_group_ids = [module.rds_sg.security_group_id]
}



locals {
  rds_cidr_blocks = ["102.89.83.23/32", data.aws_vpc.default.cidr_block]
}


module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name = "Nodejs mysql SG"
  description = "Security group for rds instance mysql port open within VPC"
  vpc_id = var.vpc_id

  ingress_cidr_blocks = local.rds_cidr_blocks
  ingress_rules       = ["mysql-tcp"]
  egress_rules        = ["all-all"]
}


# local
locals {
    rds_enpoint  = element(split(":", aws_db_instance.tf_rds_instance.endpoint), 0)
}

#output
output "rds_endpoint" {
    value = local.rds_enpoint
}

output "rds_username" {
    value = aws_db_instance.tf_rds_instance.username
}

output "rds_db_name" {
    value = aws_db_instance.tf_rds_instance.db_name
}
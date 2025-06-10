variable "ami_id" {
    type = string
    description = "this is the AMI id"
    default = "ami-0731becbf832f281e"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "app_name" {
    default = "Nodejs Server"
}

variable "vpc_id" {
    type = string
    default = "vpc-03bde13c799be5c76"
} 

variable mysql_username {
    type = string
    default = "admin"
}


variable "mysql_password" {
    type = string
    default = "abraham123"
}
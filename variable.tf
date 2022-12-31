variable "region" {
  default = "ap-south-1"
}

variable "subnet_count" {
  default = "3"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "asg_min" {
  default = 1
}

variable "asg_max" {
  default = 2
}

variable "vpc_cidr" {
  default = "10.10.10.0/24"
}
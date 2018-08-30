variable "region" {
  description = "The AWS region."
}

variable "environment" {
  description = "The name of our environment, i.e. development."
}

variable "key_name" {
  description = "The AWS key pair to use for resources."
}

variable "vpc_cidr" {
  description = "The CIDR of the VPC."
}

variable "public_subnets" {
  default     = []
  description = "The list of public subnets to populate."
}

variable "private_subnets" {
  default     = []
  description = "The list of private subnets to populate."
}

variable "ami" {
  default = {
    "us-east-1" = "ami-f652979b"
    "us-west-1" = "ami-7c4b331c"
    "eu-west-1" = "ami-0ae77879"
  }

  description = "The AMIs to use for web and app instances."
}

variable "instance_type" {
  default     = "t2.micro"
  description = "The instance type to launch "
}

variable "vpc_id" {
  description = "The VPC ID to launch in"
}

variable "bastion_instance_type" {
  default     = "t2.micro"
  description = "The bastion host instance type."
}

variable "bastion_ami" {
  default = {
    "us-east-1" = "ami-f652979b"
    "us-west-1" = "ami-7c4b331c"
    "eu-west-1" = "ami-0ae77879"
  }

  description = "The bastion host AMIs."
}

variable "enable_dns_hostnames" {
  description = "Should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  default     = true
}

output "vpc_id" {
  value = "${aws_vpc.environment.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.environment.cidr_block}"
}

output "bastion_host_dns" {
  value = "${aws_instance.bastion.public_dns}"
}

output "bastion_host_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "public_subnet_ids" {
  value = "${aws_subnet.public.*.id}"
}

output "private_subnet_ids" {
  value = "${aws_subnet.private.*.id}"
}

output "public_route_table_id" {
  value = "${aws_route_table.public.id}"
}

output "private_route_table_id" {
  value = "${aws_route_table.private.*.id}"
}

output "default_security_group_id" {
  value = "${aws_vpc.environment.default_security_group_id}"
}

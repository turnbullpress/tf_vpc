variable "name" {}
variable "cidr" {}
variable "public_subnet" {}

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

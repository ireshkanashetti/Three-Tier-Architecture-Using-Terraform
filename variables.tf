variable "region" {
  default = "eu-north-1"
}
variable "vpc-cidr-block" {
  default = "10.0.0.0/16"
}
variable "project-name" {
  default = "3tire"
}
variable "private-sub1-cidr" {
  default = "10.0.0.0/20"
}
variable "az1" {
  default = "eu-north-1a"
}
variable "private-sub2-cidr" {
 default = "10.0.16.0/20"
}
variable "az2" {
  default = "eu-north-1b"
}
variable "public-sub-cidr" {
  default = "10.0.32.0/20"
}
variable "az3" {
  default = "eu-north-1a"
}
variable "igw-cidr" {
  default = "0.0.0.0/0"
}
variable "ami" {
  default = "ami-0b46816ffa1234887"
}
variable "instance_type" {
  default = "t3.micro"
}
variable "key_name" {
  default = "jenkin"
}
variable "nat-cidr" {
  default = "0.0.0.0/0"
}
variable "sub-nat-cidr" {
  default = "0.0.0.0/0"
}
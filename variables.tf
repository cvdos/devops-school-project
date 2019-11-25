variable "aws-region" {
  type        = "string"
  description = "AWS region"
}
# variable "aws-availability-zones" {
#   type        = "string"
#   description = "AWS zones"
# }
variable "vpc-name" {
  type        = "string"
  description = "VPC name"
}
variable "vpc-cidr" {
  type        = "string"
  description = "VPC CIDR"
}
variable "my-ip" {
  type        = "string"
  description = "My ip address"
}
variable "dos-key" {
  type        = "string"
  description = "Public ssh-rsa key"
}
variable "mongo-ami" {
  type        = "string"
  description = "MongoDB 3.4 Ubuntu 16.04 AMI"
}
variable "bastion-ami" {
  type        = "string"
  description = "Bastion host AMI"
}

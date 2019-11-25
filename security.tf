# MY IP ADDRESS LOCATION
data "http" "my-ipaddress" {
  url = "${var.my-ip}"
}

# CREATE SECURITY GROUPS WITH RULES
# security group allows remote connection to bastion host
resource "aws_security_group" "dos-bastion-access" {
  name        = "dos-bastion-access"
  description = "Allow access to bastion host"
  vpc_id      = "${aws_vpc.dos-vpc.id}"
  tags = {
    Name = "dos-bastion-access"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my-ipaddress.body)}/32"]
    description = "Allow SSH connection to bastion host"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# security group allows connection to private area hosts from bastion over SSH
resource "aws_security_group" "dos-private-access" {
  name        = "dos-private-access"
  description = "Allow access to private network hosts"
  vpc_id      = "${aws_vpc.dos-vpc.id}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "dos-private-access"
  }
}
resource "aws_security_group_rule" "dos-private-access-ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.dos-private-access.id}"
  source_security_group_id = "${aws_security_group.dos-bastion-access.id}"
}
# security group allows connection to MongoDB host
resource "aws_security_group" "dos-mongodb-connect" {
  name        = "dos-mongodb-connect"
  description = "Allow connection to MongoDB"
  vpc_id      = "${aws_vpc.dos-vpc.id}"
  tags = {
    Name = "dos-mongodb-connect"
  }
}
resource "aws_security_group_rule" "dos-mongodb-ingress" {
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  self              = true
  security_group_id = "${aws_security_group.dos-mongodb-connect.id}"
}
resource "aws_security_group_rule" "dos-mongodb-egress" {
  type              = "egress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  self              = true
  security_group_id = "${aws_security_group.dos-mongodb-connect.id}"
}
# for replication servers only
# resource "aws_security_group" "dos-mongodb-replica" {
#   name        = "dos-mongodb-replica"
#   description = "Allow MongoDB replication"
#   vpc_id      = "${aws_vpc.dos-vpc.id}"
#   tags = {
#     Name = "dos-mongodb-replica"
#   }
# }
# resource "aws_security_group_rule" "dos-mongodb-replica" {
#   type              = "ingress"
#   from_port         = 27017
#   to_port           = 27019
#   protocol          = "tcp"
#   self              = true
#   security_group_id = "${aws_security_group.dos-mongodb-replica.id}"
# }
# Redis security group
# resource "aws_security_group" "dos-redis" {
#   name        = "dos-redis"
#   description = "Allow connection to Redis host"
#   vpc_id      = "${aws_vpc.dos-vpc.id}"
#   tags = {
#     Name = "dos-redis"
#   }
# }
# resource "aws_security_group_rule" "dos-redis-ingress" {
#   type              = "ingress"
#   from_port         = 6379
#   to_port           = 6379
#   protocol          = "tcp"
#   self              = true
#   security_group_id = "${aws_security_group.dos-redis.id}"
# }
# resource "aws_security_group_rule" "dos-redis-egress" {
#   type              = "egress"
#   from_port         = 6379
#   to_port           = 6379
#   protocol          = "tcp"
#   self              = true
#   security_group_id = "${aws_security_group.dos-redis.id}"
# }
# CREATE KEY PAIR
resource "aws_key_pair" "dos-key" {
  key_name   = "dos-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCZj1m6di8Ia/g8TiBp9f/pZUMNYbLpa6PqV+XMS1PMycWy63uz/Pnb9B25tFb3PE1Mkmc6TWWlHvD/0rAuiZLklXf6aP6tEUPcRN1fQ1IZeF9ZPH7ntW0kEEZVDHboEi7IWicvUbg9YFGui7HjM6zkwaOsayqWqI5bL1y6nZExJYfJFL23864FmrjS4sEm0xDkknmSTEL3nLn5Zu/EkSqHEWWg6UgqHs4vEbbN61k+fqcETklpZFCtrGQlSRxxuMwWmAUwXRiXJmd9IQIoVSBADLWY/4F4mtQznuYdol7hKJf7SMPglXyeFEpPZCcuoc2LFOWLjotPj0JDdffHfJp7 kukushioku@DESKTOP-85ERL4C"
}

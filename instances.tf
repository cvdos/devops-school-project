resource "aws_instance" "dos-bastion" {
  count                  = 1
  ami                    = "${var.bastion-ami}"
  instance_type          = "t2.micro"
  key_name               = "dos-key"
  vpc_security_group_ids = [aws_security_group.dos-bastion-access.id]
  subnet_id              = "${aws_subnet.dos-subnet-public-a.id}"
  tags = {
    Name = "dos-bastion"
  }
}
resource "aws_instance" "dos-mongodb" {
  count                  = 1
  ami                    = "${var.mongo-ami}"
  instance_type          = "t2.micro"
  key_name               = "dos-key"
  vpc_security_group_ids = [aws_security_group.dos-private-access.id, aws_security_group.dos-mongodb-connect.id]
  subnet_id              = "${aws_subnet.dos-subnet-db-a.id}"
  private_ip             = "${cidrhost(cidrsubnet(var.vpc-cidr, 8, 3), 101)}"
  tags = {
    Name = "dos-mongodb"
  }
}

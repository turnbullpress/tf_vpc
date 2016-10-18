resource "aws_vpc" "environment" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

  tags {
    Name = "${var.environment}"
  }
}

resource "aws_internet_gateway" "environment" {
  vpc_id = "${aws_vpc.environment.id}"

  tags {
    Name = "${var.environment}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.environment.id}"

  tags {
    Name = "${var.environment}-public"
  }
}

resource "aws_route_table" "private" {
  count  = "${length(var.private_subnets)}"
  vpc_id = "${aws_vpc.environment.id}"

  tags {
    Name = "${var.environment}-private"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.environment.id}"
}

resource "aws_route" "private_nat_gateway" {
  count                  = "${length(var.private_subnets)}"
  route_table_id         = "${aws_route_table.private.*.id[count.index]}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.environment.*.id[count.index]}"
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.environment.id}"
  cidr_block              = "${var.public_subnets[count.index]}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags {
    Name = "${var.environment}-public-${count.index}"
  }

  count = "${length(var.public_subnets)}"
}

resource "aws_subnet" "private" {
  vpc_id                  = "${aws_vpc.environment.id}"
  cidr_block              = "${var.private_subnets[count.index]}"
  map_public_ip_on_launch = "false"

  tags {
    Name = "${var.environment}-private-${count.index}"
  }

  count = "${length(var.private_subnets)}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets)}"
  subnet_id      = "${aws_subnet.private.*.id[count.index]}"
  route_table_id = "${aws_route_table.private.*.id[count.index]}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets)}"
  subnet_id      = "${aws_subnet.public.*.id[count.index]}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_eip" "environment" {
  count = "${length(var.public_subnets)}"

  vpc = true
}

resource "aws_nat_gateway" "environment" {
  count = "${length(var.public_subnets)}"

  allocation_id = "${aws_eip.environment.*.id[count.index]}"
  subnet_id     = "${aws_subnet.public.*.id[count.index]}"
}

resource "aws_security_group" "bastion" {
  vpc_id      = "${aws_vpc.environment.id}"
  name        = "${var.environment}-bastion-host"
  description = "Allow SSH to bastion host"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.environment}-bastion-sg"
  }
}

resource "aws_instance" "bastion" {
  ami                         = "${lookup(var.bastion_ami, var.region)}"
  instance_type               = "${var.bastion_instance_type}"
  key_name                    = "${var.key_name}"
  monitoring                  = true
  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
  subnet_id                   = "${aws_subnet.public.*.id[0]}"
  associate_public_ip_address = true

  tags {
    Name = "${var.environment}-bastion"
  }
}

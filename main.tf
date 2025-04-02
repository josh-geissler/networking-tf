# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.env}-vpc"
  }
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "${var.region}a"
    tags = {
        Name = "${var.env}-subnet"
    }
}

# Create a security group
resource "aws_security_group" "main_security_group" {
    name = "${var.env}-security-group"
    description = "Security group for the ${var.env} environment"
    vpc_id = aws_vpc.main_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Create an internet gateway
resource "aws_internet_gateway" "main_igw" {
    vpc_id = aws_vpc.main_vpc.id
    tags = {
        Name = "${var.env}-internet-gateway"
    }
}

# Create a route table
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.main_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main_igw.id
    }
    tags = {
        Name = "${var.env}-route-table"
    }
}

# Create a route table association
resource "aws_route_table_association" "public_subnet_route_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_route_table.id
}

# Create a security group rule for SSH access
resource "aws_security_group_rule" "ssh_ingress" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_group_id = aws_security_group.main_security_group.id
    source_security_group_id = aws_security_group.main_security_group.id
}


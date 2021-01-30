# VPC
resource "aws_vpc" "ntvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "nt-vpc01"
  }
}

# Public Subnet
resource "aws_subnet" "ntpubsubnet" {
  depends_on = [aws_vpc.ntvpc]

  availability_zone = "us-east-2a"
  vpc_id     = aws_vpc.ntvpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = "true"
  #availability_zone = "us-east-2a"

  tags = {
    Name = "nt-pub-subnet01"
  }
}

# Private Subnet
resource "aws_subnet" "ntprivsubnet" {
  depends_on = [aws_vpc.ntvpc]

  availability_zone = "us-east-2a"
  vpc_id     = aws_vpc.ntvpc.id
  cidr_block = "10.0.1.0/24"
  #availability_zone = "us-east-2a"

  tags = {
    Name = "nt-priv-subnet01"
  }
}

# NAT Subnet
resource "aws_subnet" "ntnatsubnet" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.ntvpc.id

  tags = {
    "Name" = "nt-nat-subnet01"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ntig" {
  depends_on = [aws_vpc.ntvpc]
  vpc_id = aws_vpc.ntvpc.id

  tags = {
    Name = "nt-ig01"
  }
}

# Route Table for Internet Gateway
resource "aws_route_table" "ntigrt" {
  depends_on = [aws_vpc.ntvpc,aws_internet_gateway.ntig]
  vpc_id = aws_vpc.ntvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ntig.id
  }

  tags = {
    Name = "nt-igrt01"
  }
}

# Private Route Table
resource "aws_route_table" "ntprivrt" {
  vpc_id = aws_vpc.ntvpc.id
  tags = {
    Name = "nt-privrt01"
  }

  depends_on = [aws_vpc.ntvpc]
}

# Associate route table to public subnet
resource "aws_route_table_association" "ntassocrtpubsubnet" {
  depends_on = [
    aws_route_table.ntigrt
  ]
  subnet_id      = aws_subnet.ntpubsubnet.id
  route_table_id = aws_route_table.ntigrt.id
}

# Associate route table to private subnet
resource "aws_route_table_association" "ntassocrtprivsubnet" {
  depends_on = [
    aws_subnet.ntnatsubnet,
    aws_route_table.ntigrt,
  ]
  subnet_id = aws_subnet.ntnatsubnet.id
  route_table_id = aws_route_table.ntigrt.id
}


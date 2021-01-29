# elastic ip
resource "aws_eip" "ntelasticip" {
  vpc      = true
#  instance = aws_instance.ntwebsvr.id

  tags = {
    Name = "nt-elastic-ip"
  }
}

# NAT gateway
resource "aws_nat_gateway" "ntnatgateway" {
  depends_on = [
    aws_subnet.ntnatgateway,
    aws_eip.ntelasticip,
  ]
  allocation_id = aws_eip.ntelasticip.id
  subnet_id     = aws_subnet.ntnatgateway.id

  tags = {
    Name = "nt-nat-gateway"
  }
}

# Route table with target as a NAT gateway
resource "aws_route_table" "ntNATroutetable" {
  depends_on = [
    aws_vpc.ntvpc,
    aws_nat_gateway.ntnatgateway,
  ]

  vpc_id = aws_vpc.ntvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ntnatgateway.id
  }

  tags = {
    Name = "nt-NAT-route-table"
  }
}

# Associate route table to private subnet
resource "aws_route_table_association" "ntassocroutetabletoprivsubnet" {
  subnet_id      = aws_subnet.ntprivsubnet.id
  route_table_id = aws_route_table.ntNATroutetable.id
}


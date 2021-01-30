# elastic ip
resource "aws_eip" "ntelasticip" {
  depends_on = [
    aws_internet_gateway.ntig
  ]
  vpc                       = true

  tags = {
    Name = "nt-elastic-ip"
  }
}

# NAT gateway
resource "aws_nat_gateway" "ntnatgateway" {
  depends_on = [
    aws_eip.ntelasticip
  ]
  allocation_id = aws_eip.ntelasticip.id
  subnet_id     = aws_subnet.ntpubsubnet.id

  tags = {
    Name = "nt-nat-gateway"
  }
}

# Route table with target as a NAT gateway
resource "aws_route_table" "ntNATroutetable" {
  depends_on = [
    aws_vpc.ntvpc
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

# Associate NAT route table to private subnet
resource "aws_route_table_association" "ntassocroutetabletoprivsubnet" {
  depends_on = [
    aws_route_table.ntNATroutetable
  ]
  subnet_id      = aws_subnet.ntprivsubnet.id
  route_table_id = aws_route_table.ntNATroutetable.id
}


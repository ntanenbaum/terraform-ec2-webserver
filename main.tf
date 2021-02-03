# Create VPC | CIDR block of 64 IPs
resource "aws_vpc" "ntvpc" {
  cidr_block           = "10.0.0.0/26"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "nt-vpc01"
  }
}

# Create an internet gateway (router connects a VPC to the internet)
resource "aws_internet_gateway" "ntvpc_igt" {
  vpc_id = aws_vpc.ntvpc.id

  tags = {
    Name = "nt-ig01"
  }
}

# Create a Public Route Table associated with VPC and allow traffic to IG
resource "aws_route_table" "ntvpc_public_rt" {
  vpc_id = aws_vpc.ntvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ntvpc_igt.id
  }

  tags = {
    Name = "nt-pubrt01"
  }
}

# Create a public subnet | map_public_ip_on_launch is true
resource "aws_subnet" "ntvpc_public_sn" {
  vpc_id                  = aws_vpc.ntvpc.id
  cidr_block              = "10.0.0.0/28"
  availability_zone_id    = "use2-az1"
  map_public_ip_on_launch = true

  tags = {
    Name = "nt-pub-subnet01"
  }
}

# Associate subnet with a IG route
resource "aws_route_table_association" "ntvpc_public_sn_route" {
  subnet_id      = aws_subnet.ntvpc_public_sn.id
  route_table_id = aws_route_table.ntvpc_public_rt.id
}

# Create a NAT Gateway on Public Subnet
# Associate to Public Subnet and the Elastic IP Address
resource "aws_nat_gateway" "ntvpc_public_sn_ng" {
  allocation_id = aws_eip.ntvpc_public_sn_ng_elastic_ip.id
  subnet_id     = aws_subnet.ntvpc_public_sn.id
}

# Create a Private Subnet
resource "aws_subnet" "ntvpc_private_sn" {
  vpc_id               = aws_vpc.ntvpc.id
  cidr_block           = "10.0.0.16/28"
  availability_zone_id = "use2-az1"

  tags = {
    Name = "nt-priv-subnet01"
  }
}

# Create a Private Route table
resource "aws_route_table" "ntvpc_private_rt" {
  vpc_id = aws_vpc.ntvpc.id

  tags = {
    Name = "nt-privrt01"
  }
}

# Add a Route in the Private Route Table to allow traffic utilizing the route to NAT Gateway 
resource "aws_route" "ntvpc_private_sn_internet_access" {
  route_table_id         = aws_route_table.ntvpc_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ntvpc_public_sn_ng.id
}

# Associate Private Subnet with a IG route
resource "aws_route_table_association" "ntvpc_private_sn_route" {
  subnet_id      = aws_subnet.ntvpc_private_sn.id
  route_table_id = aws_route_table.ntvpc_private_rt.id
}

# Create web server SG allowing web traffic to/from web instance running on Private|Public Subnets in VPC
resource "aws_security_group" "ntvpc_webserver_sg" {
  name        = "ntvpc_webserver_sg"
  description = "Allow SSH & HTTP inbound traffic"
  vpc_id      = aws_vpc.ntvpc.id

  ingress {
    description = "Allow SSH"
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    security_groups = [aws_security_group.ntvpc_bastserver_sg.id]
    #cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    description = "Allow HTTP"
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nt_websvr_secgrp"
  }
}

# Create Bastion Server security group to connect to webserver to run commands
resource "aws_security_group" "ntvpc_bastserver_sg" {
  depends_on = [aws_vpc.ntvpc]

  name        = "secgrp bastion host"
  description = "bastion host secgrp"
  vpc_id      = aws_vpc.ntvpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32", "10.0.0.16/28"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nt_bastion_secgrp"
  }

}

# Create Load Balancer | Public subnet
# Listener process to check for connection requests.
# Port for the front-end is the client to load balancer connections  
# Port for back-end is the load balancer to instance connections
resource "aws_elb" "ntlb" {
  name            = "nt-load-balancer"
  subnets         = [aws_subnet.ntvpc_public_sn.id]
  security_groups = [aws_security_group.ntvpc_webserver_sg.id]

  listener {
    instance_port     = 22
    instance_protocol = "tcp"
    lb_port           = 22
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  instances = [aws_instance.ntwebsvr.id]

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:80"
    interval            = 30
  }

  tags = {
    Name = "nt-elb01"
  }
}
#
## Testing....
# Validation on remote instance by opening the webpage on local client host 
#resource "null_resource" "ntcurl_webpage" {
#  provisioner "local-exec" {
#    command     = "curl http://${aws_elb.ntlb.dns_name}"
#  }
#
#  depends_on = [aws_elb.ntlb]
#}


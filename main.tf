# Create VPC | CIDR block of 64 IPs
resource "aws_vpc" "ntvpc" {
  cidr_block           = "10.0.0.0/26"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Create an internet gateway (virtual router that connects a VPC to the internet)
resource "aws_internet_gateway" "ntvpc_igt" {
  vpc_id = aws_vpc.ntvpc.id
}

# Route table specifies how packets are forwarded b/w subnets within your VPC, the internet and VPN connection
# Create a Public Route table associated with custom VPC and allow IpV4 traffic on Internet Gateway
resource "aws_route_table" "ntvpc_public_rt" {
  vpc_id = aws_vpc.ntvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ntvpc_igt.id
  }
}

## Public Subnet Starts
#
# Create a public subnet , ensure map_public_ip_on_launch is set to true
resource "aws_subnet" "ntvpc_public_sn" {
  vpc_id                  = aws_vpc.ntvpc.id
  cidr_block              = "10.0.0.0/28"
  availability_zone_id    = "use2-az1"
  map_public_ip_on_launch = true
}

# Associate subnet with a internet gateway route
resource "aws_route_table_association" "ntvpc_public_sn_route" {
  subnet_id      = aws_subnet.ntvpc_public_sn.id
  route_table_id = aws_route_table.ntvpc_public_rt.id
}

# Generate an Elastic IP
#resource "aws_eip" "ntvpc_public_sn_ng_elastic_ip" {
#}

# Create a Network Address Translation (NAT) Gateway on Public Subnet
# Associate to Public Subnet & an Elastic IP Address
resource "aws_nat_gateway" "ntvpc_public_sn_ng" {
  allocation_id = aws_eip.ntvpc_public_sn_ng_elastic_ip.id
  subnet_id     = aws_subnet.ntvpc_public_sn.id
}
## Public Subnet Ends
#
## Private Subnet Starts

# Create a private subnet
resource "aws_subnet" "ntvpc_private_sn" {
  vpc_id               = aws_vpc.ntvpc.id
  cidr_block           = "10.0.0.16/28"
  availability_zone_id = "use2-az1"
}

# Create a Private Route table
resource "aws_route_table" "ntvpc_private_rt" {
  vpc_id = aws_vpc.ntvpc.id
}

# Add a Route in Private Route Table to allow IpV4 traffic using route to NAT Gateway 
resource "aws_route" "ntvpc_private_sn_internet_access" {
  route_table_id         = aws_route_table.ntvpc_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ntvpc_public_sn_ng.id
}

# Associate subnet with a internet gateway route
resource "aws_route_table_association" "ntvpc_private_sn_route" {
  subnet_id      = aws_subnet.ntvpc_private_sn.id
  route_table_id = aws_route_table.ntvpc_private_rt.id
}

## Private Subnet Ends

# Create a security group to allow web traffic to/from instances running on private / public subnets in our custom VPC
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
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Bastion Server security group to connect to webserver
# Bastion Host Security Group
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
    cidr_blocks = ["${chomp(data.http.myip.body)}/32", "10.0.0.0/28", "10.0.16.0/28"]
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

# EC2 Instance in Private Subnet | No Public IP 
#resource "aws_instance" "ntwebsvr" {
#  ami                         = data.aws_ami.amazon-linux-2.id
#  instance_type               = "t2.micro"
#  subnet_id                   = aws_subnet.ntvpc_private_sn.id
#  associate_public_ip_address = false
#  vpc_security_group_ids      = [aws_security_group.ntvpc_webserver_sg.id]
#  key_name                    = var.key_name
#}

# Create Load Balancer | public subnet
# A listener is a process that checks for connection requests. It is configured with a protocol and a port for front-end (client to load balancer) connections and a protocol and a port for back-end (load balancer to instance) connections.
resource "aws_elb" "ntlb" {
  name            = "classic-load-balancer"
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
    target              = "TCP:22"
    interval            = 30
  }
}
## Provision Remote EC2 Instance
# Connect to Private EC2 Instance as ec2-user using Elastic Load Balancer DNS name backed by Public IP
# Provision remote EC2 Instance as root user to start HTTP Server which will be used for static Web App 
# Ensure to use correct Private Key from associated key_name of EC2 instance
#resource "null_resource" "ntprov_ec2" {
#  provisioner "file" {
#    source      = "/tmp/terraform_iac/ec2Key.pem"
#    destination = "/home/ec2-user/ec2Key.pem"
#
#    connection {
#    type     = "ssh"
#    user     = "ec2-user"
#    private_key = tls_private_key.private_key.private_key_pem
#    host     = aws_elb.ntlb.dns_name
#    }
#  }
#
#  depends_on = [aws_nat_gateway.ntvpc_public_sn_ng, aws_elb.ntlb, aws_instance.ntwebsvr]
#}

# Connect to private EC2 instance and provision Web Server to use custom HTML code 
#resource "null_resource" "ntprov_ec2_websvr" {
#  connection {
#    type        = "ssh"
#    user        = "ec2-user"
#    private_key = tls_private_key.private_key.private_key_pem
#    host        = aws_elb.ntlb.dns_name
#  }

#  provisioner "remote-exec" {
#    inline = [
#      "sudo chown -R ec2-user /var/www/html",
#      "sudo chmod -R 755 /var/www/html",
#      "sudo su -c \"echo \\\"<html><body bgcolor='red'><h1>My static page is working w00t!!</h2></body></html>\\\"\" >  /var/www/html/index.html"
#    ]
#  }

#  depends_on = [null_resource.ntprov_ec2, aws_elb.ntlb]
#}

# Validate our code is running fine on remote instance,Open web page on local client host 
#resource "null_resource" "ntcurl_webpage" {
#  provisioner "local-exec" {
#    command     = "curl http://${aws_elb.ntlb.dns_name}"
#  }
#
#  depends_on = [null_resource.ntprov_ec2, null_resource.ntprov_ec2_websvr, aws_elb.ntlb]
#}


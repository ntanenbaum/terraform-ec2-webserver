# Bastion Host ec2 Instance
resource "aws_instance" "ntbastioninstance" {
  depends_on = [aws_vpc.ntvpc, aws_subnet.ntprivsubnet]

  ami = data.aws_ami.amazon-linux-2.id
  #availability_zone = "us-east-2a"
  instance_type = "t2.micro"
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.ntsecgrpbh.id]
  subnet_id = aws_subnet.ntpubsubnet.id
  disable_api_termination = false
  monitoring = false

  tags = {
      Name = "nt_bastion_host"
  }

  provisioner "file" {
    source      = "/tmp/terraform_iac/ec2Key.pem"
    destination = "/home/ec2-user/ec2Key.pem"

    connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = tls_private_key.private_key.private_key_pem
    host     = aws_instance.ntbastioninstance.public_ip
    }
  }

  user_data = <<EOF
            #!/bin/bash
            chmod 600 /home/ec2-user/ec2Key.pem
  EOF
}

# Webserver ec2 Instance
resource "aws_instance" "ntwebsvr" {
  depends_on = [aws_security_group.ntsecgrpwebsvr, aws_nat_gateway.ntnatgateway, aws_route_table_association.ntassocroutetabletoprivsubnet]
  #availability_zone = "us-east-2a"
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.ntsecgrpwebsvr.id]
  subnet_id = aws_subnet.ntprivsubnet.id
  disable_api_termination = false
  monitoring = false

  tags = {
      Name = "ntwebserver01"
  }

  user_data = <<EOF
            #!/bin/bash
            yum update -y
            yum install httpd -y
            echo "<p> Hello there! My new ec2 webserver instance is running! YAY! </p>" >> /var/www/html/index.html
            systemctl restart httpd.service
            systemctl enable httpd.service
  EOF
}


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

# Elastic ip
resource "aws_eip" "ntelasticip" {
  vpc                       = true

  tags = {
    Name = "nt-elastic-ip"
  }
}

# Webserver ec2 Instance
resource "aws_instance" "ntwebsvr" {
  depends_on = [aws_vpc.ntvpc, aws_security_group.ntsecgrpwebsvr]
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.ntsecgrpwebsvr.id]
  subnet_id = aws_subnet.ntprivsubnet.id
  disable_api_termination = false
  #associate_public_ip_address = true
  monitoring = false
  user_data = file("userdataweb.sh")

  tags = {
      Name = "ntwebserver01"
  }
}

#Associate Elastic IP to Web Server
resource "aws_eip_association" "ntwebeipassoc" {
  instance_id = aws_instance.ntwebsvr.id
  allocation_id = aws_eip.ntelasticip.id
}


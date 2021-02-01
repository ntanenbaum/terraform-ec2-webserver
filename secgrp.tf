# Bastion Host Security Group
resource "aws_security_group" "ntsecgrpbh" {
  depends_on = [aws_vpc.ntvpc]

  name        = "secgrp bastion host"
  description = "bastion host secgrp"
  vpc_id      = aws_vpc.ntvpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32", "10.0.0.0/24", "10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion_secgrp"
  }

}

# Webserver Security Group
resource "aws_security_group" "ntsecgrpwebsvr" {
  depends_on = [aws_vpc.ntvpc]

  name        = "secgrp webserver"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.ntvpc.id

  ingress {
    description = "Allow TCP HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.ntsecgrpbh.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "websvr_secgrp"
  }
}


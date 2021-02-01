# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# My IP
data "http" "myip"{
    url = "https://ipv4.icanhazip.com"
}

# Policies
data "template_file" "nt_assume_role_policy" {
  template = file("${path.module}/assume_role_policy.json")
}

data "template_file" "nt_log_policy" {
  template = file("${path.module}/log_policy.json")
}


# Private key
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# AWS keypair
resource "aws_key_pair" "key_pair" {
  depends_on = [tls_private_key.private_key]
  key_name   = var.key_name
  public_key = tls_private_key.private_key.public_key_openssh
}

# Save privateKey
resource "local_file" "saveKey" {
  depends_on = [aws_key_pair.key_pair]
  content = tls_private_key.private_key.private_key_pem
  filename = "${var.base_path}${var.key_name}"
  directory_permission = 0755
  file_permission = 0600
}


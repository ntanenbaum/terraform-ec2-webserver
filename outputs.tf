output "lb_dns_name" {
  description = "Show load balancer DNS name"
  value = aws_elb.ntlb.dns_name
}

output "bast_public_ip" {
  description = "List public IP address assigned to the bastion instance"
  value       = aws_instance.ntbastioninstance.*.public_ip
}

output "bast_private_ip" {
  description = "List private IP address assigned to the bastion instance"
  value       = aws_instance.ntbastioninstance.*.private_ip
}

output "websvr_private_ip" {
  description = "List private IP address assigned to the webserver instance"
  value       = aws_instance.ntwebsvr.*.private_ip
}

output "amazon2_ami_id" {
  description = "Show latest amazon2 ami"
  value = data.aws_ami.amazon-linux-2.id
}


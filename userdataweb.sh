#!/bin/bash
yum update -y
yum install httpd -y
echo "<p> Hello World! My new ec2 web instance is running! w00t! </p>" >> /var/www/html/index.html
systemctl restart httpd.service
systemctl enable httpd.service


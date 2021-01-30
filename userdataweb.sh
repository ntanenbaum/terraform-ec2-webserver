#!/bin/bash
yum update -y
yum install httpd -y
echo "<p> Hello there! My new ec2 webserver instance is running! YAY! </p>" >> /var/www/html/index.html
systemctl restart httpd.service
systemctl enable httpd.service


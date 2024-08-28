#!/bin/bash
sudo yum install -y httpd

systemctl start httpd
systemctl enable httpd

cd /var/www/html 

echo "its public server" >> index.html

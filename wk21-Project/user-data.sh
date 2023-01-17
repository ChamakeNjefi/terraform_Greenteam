#! /bin/bash
sudo yum update
sudo yum install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>Welcome to week 21 project</h1>" > /var/www/html/index.html
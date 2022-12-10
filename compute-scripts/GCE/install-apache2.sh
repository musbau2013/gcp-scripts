#! /bin/bash 
sudo apt update -y 
sudo apt -y install apache2 
sudo apt install wget -y 
sudo wget https://storage.googleapis.com/jjtech-gcp-batch-projects/jjtechflix-app-gce-deployment/jjtech-streaming-application-v2.zip 
sudo apt install unzip -y 
sudo unzip jjtech-streaming-application-v2.zip 
sudo rm -f /var/www/html/index.html 
sudo cp -rf jjtech-streaming-application-v2/* /var/www/html/ 
sudo systemctl start apache2 
sudo systemctl enable apache2
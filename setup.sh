#!/bin/bash

echo "update system packages"
sudo apt update && sudo apt upgrade -y

echo "Installaing Java for jenkins"
sudo apt install -y openjdk-21-jdk maven docker.io
java -version

echo "install jenkins"
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins

echo "starting jenkins"
sudo systemctl start jenkins
sudo systemctl enable jenkins

echo "Jenkins has been installed and started."

# Take database credentials from user

echo "Enter the database name:"
read DB_NAME
echo "Enter the database username:"
read DB_USER
echo "Enter the database password:"
read -s DB_PASS

DB_URL="jdbc:postgresql://my-postgresql:5432/$DB_NAME"

echo "Database Name: $DB_URL"
echo "Database Username: $DB_USER"
echo "Database Password: $DB_PASS"

export DB_URL
export DB_USER
export DB_PASS



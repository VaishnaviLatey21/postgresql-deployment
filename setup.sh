#!/bin/bash

echo "update system packages"
sudo apt update && sudo apt upgrade -y

echo "Installaing Java for jenkins"
sudo apt install -y openjdk-21-jdk maven docker.io
sudo apt install -y curl
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

echo "Adding Jenkins user to Docker group"
sudo usermod -aG docker jenkins

echo "Restarting Jenkins to apply group changes"
sudo systemctl restart jenkins

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

#echo "Enter the Jenkins job name : "
#read JOB_NAME

JENKINS_URL=http://localhost:8080/jenkins/

#echo "Enter your Jenkins username:"
#read JENKINS_USER

#echo "Enter your Jenkins password:"
#read JENKINS_PASS

#CRUMB=$(curl "http://localhost:8080/jenkins//crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)" \
 #   --cookie-jar cookies.txt \
  #  --user $JENKINS_USER:$JENKINS_PASS)

#echo $CRUMB

#curl  'http://localhost:8080/jenkins//user/Admin/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken' \
 #   --user $JENKINS_USER:$JENKINS_PASS \
#    --data 'newTokenName=kb-token' \
 #   --cookie cookies.txt \
  #  -H $CRUMB

JOB_NAME="java-postgres"
JENKINS_USER="Admin"
JENKINS_API_TOKEN="113ee3725ed512ffffa4d8cf91ac6630c4"


echo "Download Jenkins CLI"
wget http://localhost:8080/jenkins/jnlpJars/jenkins-cli.jar

echo "Triggering Jenkins pipeline"
curl -i -X POST http://localhost:8080/jenkins/job/$JOB_NAME/build --user $JENKINS_USER:$JENKINS_API_TOKEN

echo "Build Complete"


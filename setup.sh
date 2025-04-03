#!/bin/bash

echo "update system packages"
sudo apt update && sudo apt upgrade -y

echo "Installaing Java "
sudo apt install -y openjdk-21-jdk 
echo "Installed Java"
java -version

echo "installing jenkins"
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

# Ensure Docker is running
echo "Checking if Docker is running..."
sudo systemctl start docker

# Take database credentials from user

echo "Enter the database name:"
read DB_NAME
echo "Enter the database username:"
read DB_USER
echo "Enter the database password:"
read -s DB_PASS

DB_URL="jdbc:postgresql://my-release-postgresql.default:5432/$DB_NAME"

POD_YAML_PATH="/var/lib/jenkins/vaishnavi/studentEntry/k8s/pod.yaml"

# Update values.yaml
echo "Updating values.yaml with new credentials..."
sed -i "s/\(password: \).*/\1\"$DB_PASS\"/" values.yaml
sed -i "s/\(username: \).*/\1\"$DB_USER\"/" values.yaml
sed -i "s/\(database: \).*/\1\"$DB_NAME\"/" values.yaml
sed -i "s/\(postgresPassword: \).*/\1\"$DB_PASS\"/" values.yaml

# Update pod.yaml correctly by modifying the value lines
echo "Updating pod.yaml with new credentials..."
sed -i "s|^\([[:space:]]*value:\).*|\1 \"$DB_URL\"|" "$POD_YAML_PATH"
sed -i "s|^\([[:space:]]*- name: DB_USER\)[[:space:]]*|\1|" "$POD_YAML_PATH"
sed -i "/name: DB_USER/{n;s|^\([[:space:]]*value:\).*|\1 \"$DB_USER\"|}" "$POD_YAML_PATH"
sed -i "/name: DB_PASS/{n;s|^\([[:space:]]*value:\).*|\1 \"$DB_PASS\"|}" "$POD_YAML_PATH"


echo "Updated values.yaml and pod.yaml"


#echo "Enter your Jenkins username:"
#read JENKINS_USER


JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

echo "Jenkins Initial Admin Password: $JENKINS_PASSWORD"
echo "Enter jenkins job name:"
read JOB_NAME

echo "Download Jenkins CLI"
wget http://localhost:8080/jenkins/jnlpJars/jenkins-cli.jar

echo "create jenkins job"
java -jar jenkins-cli.jar -s http://localhost:8080/jenkins -auth admin:$JENKINS_PASSWORD create-job $JOB_NAME < test.xml

echo "Build Jenkins pipeline"
java -jar jenkins-cli.jar -s http://localhost:8080/jenkins -auth admin:$JENKINS_PASSWORD build $JOB_NAME

echo "Build Complete"

#echo "open browser at : http://localhost:8081/swagger-ui/index.html"
#kubectl port-forward svc/student-entry 8081:8081

#!/bin/bash

echo "update system packages"
sudo apt update && sudo apt upgrade -y

echo "Installing Java..."
if ! sudo apt install -y openjdk-21-jdk; then
    echo "Failed to install Java, Exit....."
    exit 1
fi
echo "Java installed successfully"
java -version

# Check if Jenkins is installed
if dpkg -l | grep -q jenkins; then
    echo "Jenkins is already installed."
    echo "Checking Jenkins version..."
    jenkins --version
else
	echo "installing jenkins"
	sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
	https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
	echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
	https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
	/etc/apt/sources.list.d/jenkins.list > /dev/null
	sudo apt-get update
	sudo apt-get install jenkins
fi

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

# Generate the Kubernetes Secret YAML dynamically and apply it
kubectl delete secret db-secret --ignore-not-found

kubectl create secret generic db-secret \
  --from-literal=DB_USER="$DB_USER" \
  --from-literal=DB_PASS="$DB_PASS" \
  --from-literal=DB_URL="$DB_URL" \
  --from-literal=DB_NAME="$DB_NAME" \
  --from-literal=DB_POSTGRESPASS="$DB_PASS"

echo "Kubernetes secret 'db-secret' has been created successfully."

#echo "Enter your Jenkins username:"
#read JENKINS_USER

mkdir /var/lib/jenkins/vaishnavi
echo "export DB_USER=$DB_USER" >> /var/lib/jenkins/vaishnavi/.env
echo "export DB_PASS=$DB_PASS" >> /var/lib/jenkins/vaishnavi/.env
echo "export DB_NAME=$DB_NAME" >> /var/lib/jenkins/vaishnavi/.env
#echo "export DB_POSTGRESPASS=$DB_PASS" >> /var/lib/jenkins/vaishnavi/.env

JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

echo "Jenkins Initial Admin Password: $JENKINS_PASSWORD"
echo "Enter jenkins job name:"
read JOB_NAME

echo "Download Jenkins CLI"
wget http://localhost:8080/jenkins/jnlpJars/jenkins-cli.jar

# Check if test.xml exists before proceeding
if [[ ! -f "/tmp/test.xml" ]]; then
    echo "Error: test.xml file not found."
    exit 1
fi

cp /tmp/test.xml /var/lib/jenkins/vaishnavi/

# Create Jenkins job
echo "Creating Jenkins job: $JOB_NAME..."
if java -jar jenkins-cli.jar -s http://localhost:8080/jenkins -auth admin:$JENKINS_PASSWORD create-job $JOB_NAME < /var/lib/jenkins/vaishnavi/test.xml; then
	echo "Jenkins job '$JOB_NAME' created successfully."
else
	 echo "Error: Failed to create Jenkins job."
         exit 1
fi

# Build Jenkins job
# echo "Building Jenkins job: $JOB_NAME..."
# if java -jar jenkins-cli.jar -s http://localhost:8080/jenkins -auth admin:$JENKINS_PASSWORD build $JOB_NAME; then
# 	echo "Jenkins job '$JOB_NAME' build started successfully."
# else
# 	echo "Error: Failed to build Jenkins job."
# 	exit 1
# fi

# echo "Build Complete"

#echo "open browser at : http://localhost:8081/swagger-ui/index.html"
#kubectl port-forward svc/student-entry 8081:8081

pipeline {
    agent any

    environment {
	    DOCKER_IMAGE = "vaishnavi2131/postgres-java-app:latest"
	    REPO_URL = "https://github.com/VaishnaviLatey21/postgres-java-app.git"
       	    REPO_DIR = "studentEntry"
       	    K8S_POD = "studentEntry/k8s/pod.yaml"
       	    K8S_SERVICE = "studentEntry/k8s/service.yaml"
    }

    stages {
	stage('Install Dependencies') {
            steps {
                script {
                    sh '''
                        sudo apt-get update
			echo "Installing dependencies Docker, Curl..." 
                        sudo apt-get install -y curl

            echo "Installing Docker..."
                        # Add Docker's official GPG key:
                        sudo apt-get update
                        sudo apt-get -y install ca-certificates curl
                        sudo install -m 0755 -d /etc/apt/keyrings
                        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
                        sudo chmod a+r /etc/apt/keyrings/docker.asc

                        # Add the repository to Apt sources:
                        echo \
                        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
                        $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
                        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                        sudo apt-get update -y

                        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                        sudo systemctl start docker

			echo "Installing K3s..."
                        curl -sfL https://get.k3s.io | sh -
                        sudo k3s kubectl get nodes
                        
			echo "Updating K3s config permissions..."
                        sudo chown jenkins:jenkins /etc/rancher/k3s/k3s.yaml

                        export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

			echo "Installing Helm..."
                        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

			echo "Checking if Helm release 'my-release' exists..."
                        if helm list -q | grep -w "my-release"; then
				echo "'my-release' exists. Upgrading..."
				helm upgrade my-release oci://registry-1.docker.io/bitnamicharts/postgresql
			else
				
				echo "'my-release' not found. Installing..."
				. /var/lib/jenkins/vaishnavi/.env
                		echo "DB_USER=$DB_USER"
                		echo "DB_PASS=$DB_PASS"
                		echo "DB_NAME=$DB_NAME"

	                        helm install my-release oci://registry-1.docker.io/bitnamicharts/postgresql \
					--set global.postgresql.auth.postgresPassword="$DB_PASS" \
					--set global.postgresql.auth.username="$DB_USER" \
					--set global.postgresql.auth.password="$DB_PASS" \
					--set global.postgresql.auth.database="$DB_NAME"
			fi
                    '''
                }
            }
        }
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/VaishnaviLatey21/postgres-java-app.git', branch: 'master'
            }
        }

        stage('Build Project') {
            steps {
                script {
                    // dir("${REPO_DIR}") {
                        // sh './mvnw clean install -DskipTests'
                        sh 'chmod +x studentEntry/mvnw'
                        sh './studentEntry/mvnw -f studentEntry/pom.xml clean install -DskipTests'
                    // }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} -f ${REPO_DIR}/Dockerfile ${REPO_DIR}/"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh "/usr/local/bin/k3s kubectl apply -f ${K8S_POD}"
                sh "/usr/local/bin/k3s kubectl apply -f ${K8S_SERVICE}"
            }
        }

        stage('Verify Deployment') {
            steps {
                sh "/usr/local/bin/k3s kubectl get pods"
                sh "/usr/local/bin/k3s kubectl get svc"
            }
        }
    }

    post {
        success {
            echo "Deployment completed successfully!"
        }
        failure {
            echo "Deployment failed!"
        }
    }
}


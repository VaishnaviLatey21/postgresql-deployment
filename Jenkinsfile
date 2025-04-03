pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "vaishnavi2131/postgres-java-app:latest"
        K8S_DEPLOYMENT = "studentEntry/k8s/pod.yaml"
        K8S_SERVICE = "studentEntry/k8s/service.yaml"
    }

    stages {
	stage('Install Dependencies') {
            steps {
                script {
                    sh '''
                        sudo apt-get update 
                        sudo apt-get install -y maven docker.io curl
                        curl -sfL https://get.k3s.io | sh -
                        sleep 20 
                        sudo k3s kubectl get nodes
                        
                        sudo chown jenkins:jenkins /etc/rancher/k3s/k3s.yaml
                        export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
                        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
                        helm install my-release oci://registry-1.docker.io/bitnamicharts/postgresql -f values.yaml
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
                    dir('studentEntry') {
                        sh './mvnw clean install -DskipTests'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} -f studentEntry/Dockerfile studentEntry/"
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
                sh "/usr/local/bin/k3s kubectl apply -f ${K8S_DEPLOYMENT}"
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


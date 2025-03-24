pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "vaishnavi2131/postgres-java-app:latest"
        K8S_DEPLOYMENT = "studentEntry/k8s/pod.yaml"
        K8S_SERVICE = "studentEntry/k8s/service.yaml"
        DB_URL = "${DB_URL}" 
        DB_USER = "${DB_USER}"
        DB_PASS = "${DB_PASS}"
    }

    stages {
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


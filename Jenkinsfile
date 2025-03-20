pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "vaishnavi2131/postgres-java-app:latest"
        K8S_DEPLOYMENT = "k8s/pod.yaml"
        K8S_SERVICE = "k8s/service.yaml"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/VaishnaviLatey21/postgres-java-app.git', branch: 'master'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Update the build context and Dockerfile path here
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
                sh "kubectl apply -f ${K8S_DEPLOYMENT}"
                sh "kubectl apply -f ${K8S_SERVICE}"
            }
        }

        stage('Verify Deployment') {
            steps {
                sh "kubectl get pods"
                sh "kubectl get svc"
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


pipeline {
    agent any
    environment {
        // Define the Docker image tag
        DOCKER_IMAGE = 'spring-petclinic:latest'
        // Define your Artifactory repository key
        ARTIFACTORY_REPO = 'docker-jfrog'
    }
    tools {
        // Ensure Maven is defined in your Jenkins configuration
        maven 'Jenkins Managed Maven'
    }
    stages {
        stage('Build') {
            steps {
                script {
                    // Clean and install the project without running tests
                    sh 'mvn clean install -DskipTests'
                }
            }
        }
        stage('Test') {
            steps {
                // Run tests separately
                sh 'mvn test'
            }
        }
        stage('JFrog Xray Scan') {
            steps {
                script {
                    // Scan with JFrog Xray
                    sh 'jf rt build-scan ${BUILD_TAG} --fail=true'
                }
            }
        }
        stage('Docker Build') {
            steps {
                script {
                    // Build Docker image
                    sh 'docker build -t $DOCKER_IMAGE .'
                }
            }
        }
        stage('Docker Push') {
            steps {
                script {
                    // Log in and push Docker image to JFrog Artifactory
                    sh 'jf rt docker-push $DOCKER_IMAGE $ARTIFACTORY_REPO'
                }
            }
        }
    }
    post {
        always {
            // Cleanup Docker images
            sh 'docker rmi $DOCKER_IMAGE'
        }
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}

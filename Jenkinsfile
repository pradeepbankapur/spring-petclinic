pipeline {
    agent any
    environment {
        // Define the Docker image tag
        DOCKER_IMAGE = 'spring-petclinic:latest'
        // Define your Artifactory repository key
        ARTIFACTORY_REPO = 'docker-jfrog'
        // Define JFrog Artifactory details
        ARTIFACTORY_URL = 'https://jfrogspring.jfrog.io'
        ARTIFACTORY_USER = credentials('Pradeep')
        ARTIFACTORY_API_KEY = credentials('Haloofblood123')
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
                    // Configure JFrog CLI
                    sh 'jfrog rt config --url=$ARTIFACTORY_URL --user=$ARTIFACTORY_USER --apikey=$ARTIFACTORY_API_KEY'
                    // Scan with JFrog Xray
                    sh 'jfrog rt build-scan ${JOB_NAME}-${BUILD_NUMBER} --fail=true'
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
                    // Log in to JFrog Artifactory
                    sh 'jfrog rt docker-login'
                    // Push Docker image to JFrog Artifactory
                    sh 'jfrog rt docker-push $DOCKER_IMAGE $ARTIFACTORY_REPO'
                }
            }
        }
    }
    post {
        always {
            script {
                // Cleanup Docker images
                sh 'docker rmi $DOCKER_IMAGE || true'
            }
        }
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}

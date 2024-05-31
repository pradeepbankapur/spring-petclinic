pipeline {
    agent any

    tools {
        maven 'Jenkins Managed Maven'
        jdk 'JDK 17'
        jfrog 'jfrog-cli'
    }

    environment {
        ARTIFACTORY_URL = 'jfrogspring.jfrog.io'
        MAVEN_REPO = 'spring-petclinic-maven'
        DOCKER_REPO = 'docker-jfrog'
        DOCKER_IMAGE = 'spring-petclinic'
    }

    stages {
        stage('Compile') {
            steps {
                sh 'mvn -B clean compile'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'mvn -B test'
            }
        }

        stage('XRay Scan') {
            steps {
               sh "jf rt build-collect-env ${env.JOB_NAME} ${env.BUILD_NUMBER}"
               sh "jf rt build-add-git ${env.JOB_NAME} ${env.BUILD_NUMBER}"
               sh "jf build-scan ${env.JOB_NAME} ${env.BUILD_NUMBER}"
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    def app = docker.build("${DOCKER_IMAGE}:${env.BUILD_ID}")
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    docker.withRegistry("https://${ARTIFACTORY_URL}", 'jfrog-creds') {
                        docker.image("${ARTIFACTORY_URL}/${DOCKER_REPO}/${DOCKER_IMAGE}:${env.BUILD_ID}").push()
                    }
                }
            }
        }

        stage('Clean Up') {
            steps {
                sh 'docker rmi $(docker images -q)'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}

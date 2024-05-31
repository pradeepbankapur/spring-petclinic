pipeline {
    agent any

    tools {
        maven 'Jenkins Managed Maven'
        jdk 'JDK 17'
    }

    environment {
        DOCKER_IMAGE = 'spring-petclinic'
        ARTIFACTORY_URL = 'jfrogspring.jfrog.io/docker-jfrog'
        JFROG_CLI = 'JFrogCLI'  // Ensure this is configured in your Jenkins tools
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

        stage('Package') {
            steps {
                sh 'mvn -B package'
            }
        }

        stage('XRay Scan') {
            steps {
                script {
                    sh "./jfrog rt scan ${ARTIFACTORY_URL}/${DOCKER_IMAGE}:${env.BUILD_ID} --server-id=jfrog-server"
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    def app = docker.build("${ARTIFACTORY_URL}/${DOCKER_IMAGE}:${env.BUILD_ID}")
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    docker.withRegistry("https://${ARTIFACTORY_URL}", 'jfrog-creds') {
                        docker.image("${ARTIFACTORY_URL}/${DOCKER_IMAGE}:${env.BUILD_ID}").push()
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

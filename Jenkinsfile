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
        JFROG_ACCESS_TOKEN = credentials('artifactory-access-token')
    }

    stages {
        stage('Configure JFrog CLI') {
            steps {
                script {
                    sh "jf rt config --url https://${ARTIFACTORY_URL} --access-token ${JFROG_ACCESS_TOKEN} --interactive=false"
                }
            }
        }
        
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
                sh "jf rt bce '${env.JOB_NAME}' '${env.BUILD_NUMBER}'"
                sh "jf rt bag '${env.JOB_NAME}' '${env.BUILD_NUMBER}'"
                sh "jf rt bs '${env.JOB_NAME}' '${env.BUILD_NUMBER}'"
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

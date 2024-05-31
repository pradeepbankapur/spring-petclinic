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
         stage('Configure JFrog CLI') {
            steps {
                withCredentials([string(credentialsId: 'artifactory-access-token', variable: 'JFROG_ACCESS_TOKEN')]) {
                    sh """
                        jf c add \
                        --url https://${ARTIFACTORY_URL} \
                        --access-token ${JFROG_ACCESS_TOKEN} \
                        --interactive=false
                    """
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

      stage('Publish Build Info') {
            steps {
                withCredentials([string(credentialsId: 'artifactory-access-token', variable: 'JFROG_ACCESS_TOKEN')]) {
                    sh """
                        jf rt build-collect-env '${env.JOB_NAME}' '${env.BUILD_NUMBER}'
                    """
                    sh """
                        jf rt build-add-git '${env.JOB_NAME}' '${env.BUILD_NUMBER}'
                    """
                    sh """
                        jf rt build-publish '${env.JOB_NAME}' '${env.BUILD_NUMBER}'
                    """
                }
            }
        }

        stage('XRay Scan') {
            steps {
                withCredentials([string(credentialsId: 'artifactory-access-token', variable: 'JFROG_ACCESS_TOKEN')]) {
                    sh """
                        jf bs '${env.JOB_NAME}' '${env.BUILD_NUMBER}'
                    """
                }
            }
        }

        stage('Docker Build') {
            steps {
                withCredentials([string(credentialsId: 'artifactory-access-token', variable: 'JFROG_ACCESS_TOKEN')]) {
                    sh """
                        jf docker build ${ARTIFACTORY_URL}/${DOCKER_REPO}/${DOCKER_IMAGE}:${env.BUILD_ID} .
                    """
                }
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([string(credentialsId: 'artifactory-access-token', variable: 'JFROG_ACCESS_TOKEN')]) {
                    sh """
                        jf docker push ${ARTIFACTORY_URL}/${DOCKER_REPO}/${DOCKER_IMAGE}:${env.BUILD_ID}
                    """
                }
            }
        }

        stage('Clean Up') {
            steps {
                withCredentials([string(credentialsId: 'artifactory-access-token', variable: 'JFROG_ACCESS_TOKEN')]) {
                    sh """
                        jf docker rmi \$(jf docker images --quiet)
                    """
                }
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

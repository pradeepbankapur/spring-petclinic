pipeline {
    agent any
    environment {
        JFROG_CLI_HOME = "${env.WORKSPACE}/jfrog-cli"
        ARTIFACTORY_SERVER = 'jfrog-server'
        DOCKER_IMAGE = 'docker-jfrog'
    }
    tools {
        jfrog 'JFrogCLI'
    }
    stages {
        stage('Setup JFrog CLI') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'jfrog-creds', usernameVariable: 'JFROG_USER', passwordVariable: 'JFROG_PASSWORD')]) {
                    sh 'jfrog config add my-server --url=https://jfrogspring.jfrog.io --user=$JFROG_USER --password=$JFROG_PASSWORD --interactive=false'
                }
            }
        }
        stage('Build') {
            steps {
                sh 'mvn clean install'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('JFrog Xray Scan') {
            steps {
                sh 'jfrog rt build-collect-env spring-petclinic ${BUILD_NUMBER}'
                sh 'jfrog rt build-add-dependencies spring-petclinic ${BUILD_NUMBER} "**/*.jar"'
                sh 'jfrog rt build-publish spring-petclinic ${BUILD_NUMBER}'
                sh 'jfrog rt bs spring-petclinic ${BUILD_NUMBER}'
            }
        }
        stage('Docker Build') {
            steps {
                script {
                    def dockerImageTag = "${env.BUILD_NUMBER}"
                    sh "docker build -t ${DOCKER_IMAGE}:${dockerImageTag} ."
                }
            }
        }
        stage('Publish Docker Image to Artifactory') {
            steps {
                script {
                    def dockerImageTag = "${env.BUILD_NUMBER}"
                    sh "jfrog rt docker-push ${DOCKER_IMAGE}:${dockerImageTag} my-docker-repo --build-name=spring-petclinic --build-number=${BUILD_NUMBER}"
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}

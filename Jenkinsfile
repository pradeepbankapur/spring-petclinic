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

        stage('XRay Scan Setup') {
            steps {
                script {
                    sh "jf mvn-config --server-id-resolve=jfrog-server --server-id-deploy=jfrog-server --repo-resolve-releases=spring-petclinic-maven --repo-resolve-snapshots=spring-petclinic-maven --repo-deploy-releases=spring-petclinic-maven --repo-deploy-snapshots=spring-petclinic-maven"
                }
            }
        }

        stage('XRay Scan') {
            steps {
                script {
                    def buildName = env.JOB_NAME
                    def buildNumber = env.BUILD_NUMBER
                    def buildInfo = 'build-info.json'

                    // Run Maven build with JFrog CLI, capturing build information
                    sh "jf mvn clean install -DskipTests --build-name=${buildName} --build-number=${buildNumber} --module=${buildName} --build-info-output-file=${buildInfo}"

                    // Collect environment variables
                    sh "jf rt build-collect-env ${buildName} ${buildNumber}"

                    // Add build dependencies
                    sh "jf rt build-add-dependencies ${buildName} ${buildNumber}"

                    // Perform XRay scan and fail the build if any vulnerabilities are found
                    sh "jf rt build-scan ${buildName} ${buildNumber} --fail=true"
                }
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

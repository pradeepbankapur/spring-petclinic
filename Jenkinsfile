pipeline {
  agent any
  environment {
    MAVEN_OPTS = "-s /home/ubuntu/.m2/settings.xml"
  }
  stages {
    stage('Build') {
      steps {
        echo 'Building...'
        sh 'mvn ${MAVEN_OPTS} clean package'
      }
    }
    stage('Test') {
      steps {
        echo 'Testing...'
        sh 'mvn ${MAVEN_OPTS} test'
      }
    }
  }
  post {
    always {
      echo 'Cleaning up...'
      sh 'mvn ${MAVEN_OPTS} clean'
    }
  }
}

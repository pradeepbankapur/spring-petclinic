pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        echo 'Building...'
        sh 'mvn clean package'
      }
    }
    stage('Test') {
      steps {
        echo 'Testing...'
        sh 'mvn test'
      }
    }
  }
  post {
    always {
      echo 'Cleaning up...'
      sh 'mvn clean'
    }
  }
}

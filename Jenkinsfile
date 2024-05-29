pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        echo 'Building...'
        sh 'mvn -s /home/ubuntu/.m2/settings.xml clean package'
      }
    }
    stage('Test') {
      steps {
        echo 'Testing...'
        sh 'mvn -s /home/ubuntu/.m2/settings.xml test'
      }
    }
  }
  post {
    always {
      echo 'Cleaning up...'
      sh 'mvn -s /home/ubuntu/.m2/settings.xml clean'
    }
  }
}

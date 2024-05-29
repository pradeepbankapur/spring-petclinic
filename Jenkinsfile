pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        echo 'Building...'
        sh 'mvn -s /var/lib/jenkins/.m2/settings.xml clean package'
      }
    }
    stage('Test') {
      steps {
        echo 'Testing...'
        sh 'mvn -s /var/lib/jenkins/.m2/settings.xml test'
      }
    }
  }
  post {
    always {
      echo 'Cleaning up...'
      sh 'mvn -s /var/lib/jenkins/.m2/settings.xml clean'
    }
  }
}

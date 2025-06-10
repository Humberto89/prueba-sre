pipeline {
  agent {
    kubernetes {
      yamlFile 'deployment-cluster/jenkins/jenkins-agent.yaml'
      defaultContainer 'jnlp'  // Este contenedor debe existir en tu YAML
    }
  }

  environment {
    DOCKERHUB_USER = "kaido19"
    IMAGE_NAME = "hello-world"
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', credentialsId: 'github-creds', url: 'https://github.com/Humberto89/prueba-sre.git'
      }
    }

    stage('Build Docker Image') {
      steps {
        container('docker') {
          sh 'docker build -t $DOCKERHUB_USER/$IMAGE_NAME:latest .'
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        container('docker') {
          withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
            sh 'echo $PASS | docker login -u $USER --password-stdin'
            sh 'docker push $DOCKERHUB_USER/$IMAGE_NAME:latest'
          }
        }
      }
    }

    stage('Deploy to EKS') {
      steps {
        container('kubectl') {
          sh 'kubectl set image deployment/hello-world hello-world=$DOCKERHUB_USER/$IMAGE_NAME:latest -n dev'
        }
      }
    }
  }
}

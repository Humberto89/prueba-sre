pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
spec:
  containers:
    - name: docker
      image: docker:24.0.2
      command:
        - cat
      tty: true
    - name: kubectl
      image: bitnami/kubectl:latest
      command:
        - cat
      tty: true
    - name: jnlp
      image: jenkins/inbound-agent:latest
"""
      defaultContainer 'jnlp'
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

    stage('Deploy Resources') {
      steps {
        container('kubectl') {
          sh 'kubectl apply -f microservice/hello-world/deployment.yaml -n dev'
          sh 'kubectl apply -f microservice/hello-world/service.yaml -n dev'
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

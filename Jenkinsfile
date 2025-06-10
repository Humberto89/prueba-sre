pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: slave
spec:
  containers:
    - name: docker
      image: docker:24.0.2
      command:
        - cat
      tty: true
      securityContext:
        privileged: true
      env:
        - name: DOCKER_HOST
          value: tcp://localhost:2375
        - name: DOCKER_TLS_CERTDIR
          value: ""
      volumeMounts:
        - name: docker-graph-storage
          mountPath: /var/lib/docker
        - name: workspace-volume
          mountPath: /home/jenkins/agent
    - name: docker-dind
      image: docker:24.0.2-dind
      securityContext:
        privileged: true
      env:
        - name: DOCKER_TLS_CERTDIR
          value: ""
      volumeMounts:
        - name: docker-graph-storage
          mountPath: /var/lib/docker
    - name: kubectl
      image: bitnami/kubectl:latest
      command:
        - cat
      tty: true
      volumeMounts:
        - name: workspace-volume
          mountPath: /home/jenkins/agent
  volumes:
    - name: docker-graph-storage
      emptyDir: {}
    - name: workspace-volume
      emptyDir: {}
  restartPolicy: Never
"""
        }
    }

    environment {
        DOCKER_IMAGE = 'kaido19/hello-world:latest'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Humberto89/prueba-sre.git', branch: 'main', credentialsId: 'github-creds'
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {
                    sh 'docker version'
                    sh "docker build -t $DOCKER_IMAGE ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        sh "docker push $DOCKER_IMAGE"
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
                    sh 'kubectl rollout status deployment/hello-world -n dev'
                }
            }
        }
    }
}

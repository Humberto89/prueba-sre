pipeline {
    agent {
        kubernetes {
            label "hello-world-pipeline"
            defaultContainer 'jnlp'
            yaml """
apiVersion: v1
kind: Pod
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
        - name: workspace-volume
          mountPath: /home/jenkins/agent

    - name: kubectl
      image: bitnami/kubectl:1.27.4-debian-11-r0
      command:
        - /bin/sh
        - -c
        - cat
      tty: true
      stdin: true
      volumeMounts:
        - name: workspace-volume
          mountPath: /home/jenkins/agent

  volumes:
    - name: docker-graph-storage
      emptyDir: {}
    - name: workspace-volume
      emptyDir: {}
"""
        }
    }

    environment {
        IMAGE_NAME = 'kaido19/hello-world:latest'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Humberto89/prueba-sre.git',
                    credentialsId: 'github-creds'
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {
                    sh 'chmod +x wait-for-dind.sh'
                    sh './wait-for-dind.sh'
                    sh "docker build -t ${env.IMAGE_NAME} microservice/hello-world"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${env.IMAGE_NAME}"
                    }
                }
            }
        }

        stage('Configure Kube Access') {
            steps {
                container('kubectl') {
                    withCredentials([string(credentialsId: 'eks-kube-token', variable: 'K8S_TOKEN')]) {
                        sh 'echo "$K8S_TOKEN" > /tmp/kubeconfig'
                        sh 'export KUBECONFIG=/tmp/kubeconfig'
                        sh 'kubectl version --client'
                    }
                }
            }
        }

        stage('Deploy Resources') {
            steps {
                container('kubectl') {
                    sh '''
                        export KUBECONFIG=/tmp/kubeconfig
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                container('kubectl') {
                    sh '''
                        export KUBECONFIG=/tmp/kubeconfig
                        kubectl rollout status deployment/hello-world
                        kubectl get all
                    '''
                }
            }
        }
    }
}

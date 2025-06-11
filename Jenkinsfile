pipeline {
    agent {
        kubernetes {
            label 'hello-world-pipeline'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: hello-world-pipeline
spec:
  containers:
    - name: docker
      image: docker:24.0.2
      command:
        - cat
      tty: true
      env:
        - name: DOCKER_HOST
          value: tcp://localhost:2375
        - name: DOCKER_TLS_CERTDIR
          value: ""
      securityContext:
        privileged: true
      volumeMounts:
        - mountPath: /var/lib/docker
          name: docker-graph-storage
        - mountPath: /home/jenkins/agent
          name: workspace-volume

    - name: docker-dind
      image: docker:24.0.2-dind
      securityContext:
        privileged: true
      env:
        - name: DOCKER_TLS_CERTDIR
          value: ""
      volumeMounts:
        - mountPath: /var/lib/docker
          name: docker-graph-storage
        - mountPath: /home/jenkins/agent
          name: workspace-volume

    - name: kubectl
      image: bitnami/kubectl:1.27.4-debian-11-r0
      command:
        - /bin/sh
        - -c
        - cat
      tty: true
      stdin: true
      volumeMounts:
        - mountPath: /home/jenkins/agent
          name: workspace-volume

  volumes:
    - name: docker-graph-storage
      emptyDir: {}
    - name: workspace-volume
      emptyDir: {}
"""
        }
    }

    environment {
        DOCKER_IMAGE = "kaido19/hello-world:latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github-creds', url: 'https://github.com/Humberto89/prueba-sre.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {
                    sh 'chmod +x wait-for-dind.sh'
                    sh './wait-for-dind.sh'
                    sh "docker build -t ${DOCKER_IMAGE} microservice/hello-world"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }

        stage('Configure Kube Access') {
            steps {
                container('kubectl') {
                    withCredentials([string(credentialsId: 'k8s-token', variable: 'K8S_TOKEN')]) {
                        sh '''
                        mkdir -p $HOME/.kube
                        echo "
apiVersion: v1
clusters:
- cluster:
    server: https://<your-cluster-endpoint>
    insecure-skip-tls-verify: true
  name: my-cluster
contexts:
- context:
    cluster: my-cluster
    user: jenkins
  name: jenkins-context
current-context: jenkins-context
kind: Config
preferences: {}
users:
- name: jenkins
  user:
    token: ${K8S_TOKEN}
" > $HOME/.kube/config
                        '''
                    }
                }
            }
        }

        stage('Deploy Resources') {
            steps {
                container('kubectl') {
                    sh "kubectl apply -f k8s/deployment.yaml"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                echo "Aquí iría el paso si conectaras con EKS productivo o regional"
            }
        }
    }
}

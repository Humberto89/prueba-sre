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
      image: bitnami/kubectl:1.27.4-debian-11-r0
      command:
        - /bin/sh
      args:
        - -c
        - sleep 3600
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
                    sh 'chmod +x wait-for-dind.sh'
                    sh './wait-for-dind.sh'
                    sh "docker build -t $DOCKER_IMAGE microservice/hello-world"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'dockercred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        sh "docker push $DOCKER_IMAGE"
                    }
                }
            }
        }

        stage('Configure Kube Access') {
            steps {
                container('kubectl') {
                    withCredentials([string(credentialsId: 'k8s-token', variable: 'K8S_TOKEN')]) {
                        sh '''
                            mkdir -p ~/.kube
                            cat <<EOF > ~/.kube/config
apiVersion: v1
kind: Config
clusters:
- name: eks-cluster
  cluster:
    server: https://kubernetes.default.svc
    insecure-skip-tls-verify: true
contexts:
- name: jenkins-context
  context:
    cluster: eks-cluster
    user: jenkins
    namespace: cicd
current-context: jenkins-context
users:
- name: jenkins
  user:
    token: $K8S_TOKEN
EOF
                        '''
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

pipeline {
    agent {
        kubernetes {
            inheritFrom 'hello-world-agent'
            defaultContainer 'jnlp'
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
                    withCredentials([usernamePassword(credentialsId: 'dockercred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${env.IMAGE_NAME}"
                    }
                }
            }
        }

        stage('Configure Kube Access') {
            steps {
                container('kube-aws') {
                    withCredentials([
                        usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY'),
                        string(credentialsId: 'k8s-cluster-name', variable: 'K8S_CLUSTER_NAME')
                    ]) {
                        sh '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

                            aws eks update-kubeconfig \
                                --region us-east-1 \
                                --name "$K8S_CLUSTER_NAME" \
                                --alias "$K8S_CLUSTER_NAME" \
                                --kubeconfig /tmp/kubeconfig

                            export KUBECONFIG=/tmp/kubeconfig
                            kubectl version
                        '''
                    }
                }
            }
        }

        stage('Deploy Resources') {
            steps {
                container('kube-aws') {
                    sh '''
                        export KUBECONFIG=/tmp/kubeconfig
                        kubectl apply -f microservice/hello-world/deployment.yaml
                        kubectl apply -f microservice/hello-world/service.yaml
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                container('kube-aws') {
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

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

        stage('Validate Docker Daemon') {
            steps {
                container('docker') {
                    sh '''
                        echo "✅ Comprobando si el Docker daemon está activo en localhost:2375..."
                        export DOCKER_HOST=tcp://localhost:2375

                        echo "🔍 Ejecutando curl para validar la conexión..."
                        curl -s localhost:2375/version || echo "❌ No se pudo conectar al daemon Docker"

                        echo "🏁 Resultado de docker info directo (esperado: error si no está listo):"
                        docker info || echo "❌ docker info falló, daemon no disponible"
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {
                    sh '''
                        export DOCKER_HOST=tcp://localhost:2375
                        chmod +x wait-for-dind.sh
                        ./wait-for-dind.sh
                        docker build -t ${IMAGE_NAME} microservice/hello-world
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'dockercred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                            export DOCKER_HOST=tcp://localhost:2375
                            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                            docker push ${IMAGE_NAME}
                        '''
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
                        kubectl apply -f microservice/hello-world/deployment.yaml -n dev
                        kubectl apply -f microservice/hello-world/service.yaml -n dev
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                container('kube-aws') {
                    sh '''
                        export KUBECONFIG=/tmp/kubeconfig
                        kubectl rollout status deployment/hello-world -n dev
                        kubectl get all -n dev
                    '''
                }
            }
        }
    }
}

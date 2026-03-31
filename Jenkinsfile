pipeline {
    agent any

    environment {
        DOCKER_CREDS = credentials('docker-registry-creds')
        KUBECONFIG = credentials('k8s-cluster-config')
    }

    stages {
        stage('Initialize Polyglot Mesh') {
            steps {
                echo 'Bootstrapping ACOS Ecosystem...'
                sh 'make lint'
            }
        }
        stage('Distributed Build') {
            parallel {
                stage('Python AI Core') {
                    steps {
                        sh 'docker build -t acos/ai-core ./services/ai-python'
                    }
                }
                stage('Node Gateway') {
                    steps {
                        sh 'docker build -t acos/gateway ./services/gateway-ultimate'
                    }
                }
                stage('Rust Analytics') {
                    steps {
                        sh 'docker build -t acos/rust-analytics ./services/analytics-rust'
                    }
                }
                stage('Flutter Web UI') {
                    steps {
                        sh 'docker build -t acos/flutter-web ./frontend'
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Master Cluster...'
                sh 'make k8s-apply'
            }
        }
    }
}

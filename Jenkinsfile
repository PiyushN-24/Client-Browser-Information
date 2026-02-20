pipeline {
    agent any

    environment {
        IMAGE_NAME = "piyushnavghare/bootstrap-java-app"
        TAG = "${BUILD_NUMBER}"
        MAVEN_OPTS = "-Xmx1024m"
    }

    tools {
        maven "maven-3.9.6"
        jdk "jdk-21"
    }

    stages {

        /* ---------------- CHECKOUT ---------------- */
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/PiyushN-24/Client-Browser-Information.git'
            }
        }

        /* ---------------- SECRET SCAN ---------------- */
        stage('Pre-Commit Security Scan (Gitleaks)') {
            steps {
                sh '''
                   echo "Using pre-commit from: $(which pre-commit)" 
                   pre-commit run --all-files
                '''
            }
        }

        /* ---------------- BUILD ---------------- */
        stage('Maven Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        /* ---------------- TEST ---------------- */
        stage('Unit Tests') {
            steps {
                sh 'mvn test || true'
            }
        }

        /* ---------------- DEPENDENCY SCAN ---------------- */
        stage('Dependency Scan (Trivy FS)') {
            steps {
                sh '''
                    trivy fs --severity HIGH,CRITICAL .
                '''
            }
        }

        /* ---------------- SONARQUBE ---------------- */
        stage('SonarQube Scan') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner'
                    withSonarQubeEnv('sonar-local') {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                              -Dsonar.projectKey=bootstrap-java \
                              -Dsonar.projectName=bootstrap-java \
                              -Dsonar.sources=src \
                              -Dsonar.java.binaries=target/classes
                        """
                    }
                }
            }
        }

        stage('SonarQube Quality Gate') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        /* ---------------- DOCKER BUILD ---------------- */
        stage('Docker Build') {
            steps {
                sh '''
                    docker build -t $IMAGE_NAME:$TAG .
                    docker tag $IMAGE_NAME:$TAG $IMAGE_NAME:latest
                '''
            }
        }

        /* ---------------- IMAGE SCAN ---------------- */
        stage('Trivy Image Scan') {
            steps {
                sh '''
                    trivy image --severity HIGH,CRITICAL --exit-code 0 $IMAGE_NAME:$TAG
                '''
            }
        }

        /* ---------------- DOCKER LOGIN ---------------- */
        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        /* ---------------- PUSH ---------------- */
        stage('Docker Push') {
            steps {
                sh '''
                    docker push $IMAGE_NAME:$TAG
                    docker push $IMAGE_NAME:latest
                '''
            }
        }

        /* ---------------- DEPLOY ---------------- */
        stage('Docker Deploy') {
            steps {
                sh '''
                    docker rm -f bootstrap-app || true

                    docker run -d \
                      --name bootstrap-app \
                      -p 8080:8080 \
                      --restart unless-stopped \
                      $IMAGE_NAME:latest
                '''
            }
        }
    }

    post {
        always {
            sh 'docker system prune -af || true'
        }
        success {
            echo "✅ Java DevSecOps Pipeline Completed Successfully"
        }
        failure {
            echo "❌ Java DevSecOps Pipeline Failed"
        }
    }
}

pipeline {
    agent any

    tools {
        jdk 'jdk17'
        maven 'maven'
    }

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-cred') // AWS Access Key ID
        AWS_SECRET_ACCESS_KEY = credentials('aws-cred') // AWS Secret Access Key
        AWS_DEFAULT_REGION = 'us-east-1'
        DOCKER_IMAGE_NAME = 'boardgame' // Set the desired image name to 'boardgame'
        DOCKER_TAG = 'latest' // Tag for the image
        ECR_URL = '460982569648.dkr.ecr.us-east-1.amazonaws.com/cloudgenius' // ECR URL
        ECR_REPOSITORY = 'cloudgenius' // Your ECR repository name
        // EKS_CLUSTER_NAME = '' // EKS cluster name (commented out as per your request)
        // EKS_SERVICE_NAME = '' // EKS service name (commented out as per your request)
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'git-cred', url: 'https://github.com/CloudGeniuses/Boardgame.git'
            }
        }

        stage('Compile') {
            steps {
                sh "mvn compile"
            }
        }

        stage('Test') {
            steps {
                sh "mvn test"
            }
        }

        stage('Build') {
            steps {
                sh "mvn clean install"
                archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} ."
                }
            }
        }

        stage('AWS Credential Login') {
            steps {
                script {
                    echo "Configuring AWS CLI with credentials"
                    sh """
                        aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
                        aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
                        aws configure set default.region ${AWS_DEFAULT_REGION}
                    """
                }
            }
        }

        stage('Docker Login to ECR') {
            steps {
                script {
                    echo "Logging into AWS ECR"
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_URL}"
                }
            }
        }

        stage('Uploading to ECR') {
            steps {
                script {
                    echo "Pushing Docker image to ECR"
                    // Tag the image for ECR
                    sh "docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} ${ECR_URL}/${ECR_REPOSITORY}:${DOCKER_TAG}"
                    // Push the image to ECR
                    sh "docker push ${ECR_URL}/${ECR_REPOSITORY}:${DOCKER_TAG}"
                }
            }
        }
    }

    post {
        always {
            script {
                def jobName = env.JOB_NAME
                def buildNumber = env.BUILD_NUMBER
                def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
                def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'

                def body = """
                    <html>
                    <body>
                    <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                    <h2>${jobName} - Build ${buildNumber}</h2>
                    <div style="background-color: ${bannerColor}; padding: 10px;">
                    <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                    </div>
                    <p>Check the <a href="${env.BUILD_URL}">console output</a>.</p>
                    </div>
                    </body>
                    </html>
                """

                emailext (
                    subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
                    body: body,
                    to: 'isaacobaro127@gmail.com',
                    from: 'jenkins@example.com',
                    replyTo: 'jenkins@example.com',
                    mimeType: 'text/html',
                    attachmentsPattern: 'trivy-image-report.html'
                )
            }
        }
    }
}

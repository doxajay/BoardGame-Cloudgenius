pipeline {
    agent any

    tools {
        jdk 'jdk17'
        maven 'maven'
    }

    // environment {
    //     AWS_ACCESS_KEY_ID = credentials('aws-cred')
    //     AWS_SECRET_ACCESS_KEY = credentials('aws-cred')
    //     AWS_DEFAULT_REGION = 'us-east-2'
    //     DOCKER_IMAGE_NAME = 'boardgame'
    //     DOCKER_TAG = 'latest'
    //     ECR_URL = '211125403425.dkr.ecr.us-east-2.amazonaws.com'
    //     ECR_REPOSITORY = 'cloudgenius'
    // }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'git-cred', url: 'https://github.com/CloudGeniuses/Boardgame.git'
            }
        }
    }
}

pipeline {
    agent any
    
    parameters {
        choice(name: 'DEPLOY_ENV', 
               choices: ['Development', 'Staging', 'Production'], 
               description: 'Select the environment to deploy to.')
    }

    environment {
        S3_BUCKET = ''
        APP_VERSION = '1.0.0'
        sonarHome='Sornar_HOME'
    }
    
    stages {
        stage('Setup') {
            steps {
                script {
                    //## select the S3 bucket dynamically based on environment
                    if (params.DEPLOY_ENV == 'Development') {
                        env.S3_BUCKET = 'dev-bucket'
                    } else if (params.DEPLOY_ENV == 'Staging') {
                        env.S3_BUCKET = 'staging-bucket'
                    } else if (params.DEPLOY_ENV == 'Production') {
                        env.S3_BUCKET = 'prod-bucket'
                    }
                    // ##Error1
                    echo "Selected environment: ${params.DEPLOY_ENV}"
                    echo "Using S3 Bucket: ${env.S3_BUCKET}"
                }
            }
        }
        
        stage('Code Checkout') {
            steps {
                echo '###########Checking out the code...'
                // #git webHook
                //checkout scm
            }
        }
        
        stage('Build') {
            steps {
                echo "Building version ${env.APP_VERSION}..."
                sh 'mvn clean install'
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying to ${params.DEPLOY_ENV} environment..."
                echo "Uploading files to ${env.S3_BUCKET}..."
                // Simulate upload to S3 bucket
                sh "aws s3 cp ./build/ s3://${env.S3_BUCKET}/ --recursive"
            }
        }

        stage('Post-Deployment Steps') {
            steps {
                script {
                    if (params.DEPLOY_ENV != 'Production') {
                        echo 'Running additional tests for non-production environments...'
                        sh 'mvn test'
                    } else {
                        echo 'Not running additional tests in Production.'
                        echo 'Sending deployment alert...'
                        // Simulate sending an alert
                        sh 'curl -X POST -d "Production deployment completed." https://alert-service.example.com'
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed!'
        }
        failure {
            echo 'Pipeline failed!'
        }
        success {
            echo 'Pipeline succeeded!'
        }
    }
}

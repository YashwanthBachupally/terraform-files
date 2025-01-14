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
                // ##error2
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
                        //  sending an alert
                        sh 'curl -X POST -d "Production deployment completed." https://alert-service.example.com'
                    }
                }
            }
        }
        
        stage('Prod Confirmation') {
            steps {
                script {
                    // ##### RM user confirmation
                    def userChoice = input(id: 'ProdApproval',message: 'Do you want to move changes to production?',
                                           parameters: [booleanParam(defaultValue: false, description: 'Check to move to production', name: 'Proceed_To_Prod')])
                    if (userChoice) {
                        echo 'Thankyou for approval. Proceeding to production pipeline...'
                        // Trigger the production pipeline
                        build job: 'prod-deployment-pipeline', parameters: [string(name: 'BUILD_VERSION', value: '1.0.0')] //Exit 1
                    } else {
                        echo 'Pipeline complete. Test your application at the staging URL:'
                        echo "${env.TEST_URL}"
                    }
                }
            }
    }
    }
    post {
        always {
            echo 'Pipeline execution completed!'
            //### Mail Trigger
        }
        failure {
            echo 'Pipeline failed!'
            //### Mail Trigger
        }
        success {
            echo 'Pipeline succeeded!'
            // ### Mail Trigger
        }
    }
}

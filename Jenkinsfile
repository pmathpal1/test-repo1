pipeline {
    agent any

    environment {
        // Azure credentials (make sure these are set in Jenkins)
        ARM_CLIENT_ID       = credentials('AZURE_CLIENT_ID')
        ARM_CLIENT_SECRET   = credentials('AZURE_CLIENT_SECRET')
        ARM_SUBSCRIPTION_ID = credentials('AZURE_SUBSCRIPTION_ID')
        ARM_TENANT_ID       = credentials('AZURE_TENANT_ID')

        // GitHub credentials (make sure these are set in Jenkins)
        GITHUB_CREDENTIALS = credentials('GITHUB_CREDENTIALS')  // GitHub Token for Authentication
    }

    parameters {
        string(name: 'LOCATION', defaultValue: 'eastus', description: 'Azure region')
        string(name: 'RG_NAME', defaultValue: 'test-rg1', description: 'Azure Resource Group for backend')
        string(name: 'STORAGE_ACCOUNT_NAME', defaultValue: 'pankajmathpal99001122', description: 'Storage Account for backend')
        string(name: 'CONTAINER_NAME', defaultValue: 'mycon1212', description: 'Container for storing state file')
    }

    stages {
        stage('Clone GitHub Repository') {
            steps {
                script {
                    // Clone the GitHub repository using the credentials you added in Jenkins
                    git credentialsId: 'GITHUB_CREDENTIALS', url: 'https://github.com/pmathpal1/test-repo1.git'
                }
            }
        }

        stage('Terraform Init with Remote Backend') {
            steps {
                dir('terraform/main') {
                    withEnv([
                        "ARM_CLIENT_ID=${env.ARM_CLIENT_ID}",
                        "ARM_CLIENT_SECRET=${env.ARM_CLIENT_SECRET}",
                        "ARM_SUBSCRIPTION_ID=${env.ARM_SUBSCRIPTION_ID}",
                        "ARM_TENANT_ID=${env.ARM_TENANT_ID}"
                    ]) {
                        script {
                            docker.image('hashicorp/terraform:latest').inside('--entrypoint=') {
                                sh """
                                    terraform init \
                                        -backend-config="resource_group_name=${params.RG_NAME}" \
                                        -backend-config="storage_account_name=${params.STORAGE_ACCOUNT_NAME}" \
                                        -backend-config="container_name=${params.CONTAINER_NAME}" \
                                        -backend-config="key=terraform.tfstate" \
                                        -force-copy
                                """
                            }
                        }
                    }
                }
            }
        }

        stage('Terraform Format & Validate') {
            steps {
                dir('terraform/main') {
                    docker.image('hashicorp/terraform:latest').inside('--entrypoint=') {
                        sh 'terraform fmt -check'
                        sh 'terraform validate'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform/main') {
                    docker.image('hashicorp/terraform:latest').inside('--entrypoint=') {
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform/main') {
                    docker.image('hashicorp/terraform:latest').inside('--entrypoint=') {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }
    }

    post {
        failure {
            echo 'Terraform pipeline failed!'
        }
        success {
            echo 'Terraform pipeline completed successfully!'
        }
    }
}

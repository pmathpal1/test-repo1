pipeline {
    agent any

    environment {
        ARM_CLIENT_ID       = credentials('AZURE_CLIENT_ID')
        ARM_CLIENT_SECRET   = credentials('AZURE_CLIENT_SECRET')
        ARM_SUBSCRIPTION_ID = credentials('AZURE_SUBSCRIPTION_ID')
        ARM_TENANT_ID       = credentials('AZURE_TENANT_ID')
    }

    parameters {
        string(name: 'LOCATION', defaultValue: 'eastus', description: 'Azure region')
        string(name: 'RG_NAME', defaultValue: 'test-rg1', description: 'Azure Resource Group for backend')
        string(name: 'STORAGE_ACCOUNT_NAME', defaultValue: 'pankajmathpal99001122', description: 'Storage Account for backend')
        string(name: 'CONTAINER_NAME', defaultValue: 'mycon1212', description: 'Container for storing state file')
    }

    stages {
        stage('Prepare SSH') {
            steps {
                sh '''
                    mkdir -p ~/.ssh
                    ssh-keyscan github.com > ~/.ssh/known_hosts
                    chmod 644 ~/.ssh/known_hosts
                '''
            }
        }
        
        stage('Debug SSH Keys') {
            steps {
                sh '''
                    whoami
                    ls -l ~/.ssh
                    ssh-add -l || echo "No keys loaded"
                '''
            }
        }

        stage('Checkout Code from GitHub') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: 'main']],
                    userRemoteConfigs: [[
                        url: 'git@github.com:pmathpal1/test-repo1.git',
                        credentialsId: 'github-ssh-credential'
                    ]]
                ])
            }
        }

        stage('Terraform Format & Validate') {
            steps {
                dir('terraform/main') {
                    script {
                        docker.image('hashicorp/terraform:1.5.6').inside {
                            sh 'terraform fmt -check'
                            sh 'terraform validate'
                        }
                    }
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
                            docker.image('hashicorp/terraform:1.5.6').inside {
                                sh """
                                    terraform init \
                                        -backend-config="resource_group_name=${params.RG_NAME}" \
                                        -backend-config="storage_account_name=${params.STORAGE_ACCOUNT_NAME}" \
                                        -backend-config="container_name=${params.CONTAINER_NAME}" \
                                        -backend-config="key=terraform.tfstate"
                                """
                            }
                        }
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform/main') {
                    script {
                        docker.image('hashicorp/terraform:1.5.6').inside {
                            sh 'terraform plan -out=tfplan'
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform/main') {
                    script {
                        docker.image('hashicorp/terraform:1.5.6').inside {
                            sh 'terraform apply -auto-approve tfplan'
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ Terraform pipeline completed successfully!'
        }
        failure {
            echo '❌ Terraform pipeline failed!'
        }
    }
}

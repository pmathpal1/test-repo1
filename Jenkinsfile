pipeline {
    agent any

    parameters {
        string(name: 'LOCATION', defaultValue: 'eastus', description: 'Azure region')
        string(name: 'RG_NAME', defaultValue: 'test-rg1', description: 'Azure Resource Group')
        string(name: 'STORAGE_ACCOUNT_NAME', defaultValue: 'pankajmathpal99001122', description: 'Storage Account')
        string(name: 'CONTAINER_NAME', defaultValue: 'mycon1212', description: 'Storage Container')
        booleanParam(name: 'DESTROY', defaultValue: false, description: 'Destroy infrastructure')
    }

    environment {
        ARM_CLIENT_ID       = credentials('AZURE_CLIENT_ID')
        ARM_CLIENT_SECRET   = credentials('AZURE_CLIENT_SECRET')
        ARM_SUBSCRIPTION_ID = credentials('AZURE_SUBSCRIPTION_ID')
        ARM_TENANT_ID       = credentials('AZURE_TENANT_ID')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'git@github.com:pmathpal1/code-new.git'
            }
        }

        stage('Bootstrap Backend Infra') {
            steps {
                dir('terraform/bootstrap') {
                    withEnv([
                        "ARM_CLIENT_ID=${env.ARM_CLIENT_ID}",
                        "ARM_CLIENT_SECRET=${env.ARM_CLIENT_SECRET}",
                        "ARM_SUBSCRIPTION_ID=${env.ARM_SUBSCRIPTION_ID}",
                        "ARM_TENANT_ID=${env.ARM_TENANT_ID}"
                    ]) {
                        script {
                            docker.image('hashicorp/terraform:latest').inside('--entrypoint=') {
                                sh """
                                terraform init -backend=false
                                terraform apply \
                                    -var='location=${params.LOCATION}' \
                                    -var='rg_name=${params.RG_NAME}' \
                                    -var='storage_account_name=${params.STORAGE_ACCOUNT_NAME}' \
                                    -var='container_name=${params.CONTAINER_NAME}' \
                                    -auto-approve
                                """
                            }
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

        stage('Terraform Plan') {
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
                                terraform plan \
                                  -var='location=${params.LOCATION}' \
                                  -var='rg_name=${params.RG_NAME}' \
                                  -var='storage_account_name=${params.STORAGE_ACCOUNT_NAME}' \
                                  -var='container_name=${params.CONTAINER_NAME}'
                                """
                            }
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
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
                                terraform apply \
                                  -var='location=${params.LOCATION}' \
                                  -var='rg_name=${params.RG_NAME}' \
                                  -var='storage_account_name=${params.STORAGE_ACCOUNT_NAME}' \
                                  -var='container_name=${params.CONTAINER_NAME}' \
                                  -auto-approve
                                """
                            }
                        }
                    }
                }
            }
        }

        stage('Confirm Destroy') {
            when {
                expression { params.DESTROY == true }
            }
            steps {
                input message: 'Are you sure you want to destroy the infrastructure?', ok: 'Destroy'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.DESTROY == true }
            }
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
                                terraform destroy \
                                  -var='location=${params.LOCATION}' \
                                  -var='rg_name=${params.RG_NAME}' \
                                  -var='storage_account_name=${params.STORAGE_ACCOUNT_NAME}' \
                                  -var='container_name=${params.CONTAINER_NAME}' \
                                  -auto-approve
                                """
                            }
                        }
                    }
                }
            }
        }
    }
}


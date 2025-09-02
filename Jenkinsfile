pipeline {
    agent any

    environment {
        TF_IMAGE            = 'hashicorp/terraform:1.5.6'

        // Azure Service Principal credentials from Jenkins
        ARM_CLIENT_ID       = credentials('AZURE_CLIENT_ID')
        ARM_CLIENT_SECRET   = credentials('AZURE_CLIENT_SECRET')
        ARM_SUBSCRIPTION_ID = credentials('AZURE_SUBSCRIPTION_ID')
        ARM_TENANT_ID       = credentials('AZURE_TENANT_ID')
    }

    parameters {
        string(name: 'LOCATION', defaultValue: 'eastus', description: 'Azure location for resources')
        string(name: 'RG_NAME', defaultValue: 'test-rg1', description: 'Resource Group name')
        string(name: 'STORAGE_ACCOUNT_NAME', defaultValue: 'pankajmathpal99001122', description: 'Azure Storage Account for backend')
        string(name: 'CONTAINER_NAME', defaultValue: 'mycon1212', description: 'Azure Storage container for backend state')
        booleanParam(name: 'APPLY', defaultValue: true, description: 'Apply Terraform plan automatically?')
        booleanParam(name: 'DESTROY', defaultValue: false, description: 'Destroy infrastructure instead of applying?')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'git@github.com:pmathpal1/test-repo1.git',
                    credentialsId: 'github-ssh-credential'
            }
        }

        stage('Terraform Format & Validate') {
            steps {
                dir('terraform/main') {
                    script {
                        docker.image(env.TF_IMAGE).inside {
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
                            docker.image(env.TF_IMAGE).inside {
                                sh """
                                    terraform init \
                                        -backend-config="resource_group_name=${params.RG_NAME}" \
                                        -backend-config="storage_account_name=${params.STORAGE_ACCOUNT_NAME}" \
                                        -backend-config="container_name=${params.CONTAINER_NAME}" \
                                        -backend-config="key=${env.JOB_NAME}.tfstate"
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
                        docker.image(env.TF_IMAGE).inside {
                            sh 'terraform plan -out=tfplan'
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when { expression { return params.APPLY && !params.DESTROY } }
            steps {
                dir('terraform/main') {
                    script {
                        docker.image(env.TF_IMAGE).inside {
                            sh 'terraform apply -auto-approve tfplan'
                        }
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            when { expression { return params.DESTROY } }
            steps {
                dir('terraform/main') {
                    script {
                        docker.image(env.TF_IMAGE).inside {
                            sh 'terraform destroy -auto-approve'
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

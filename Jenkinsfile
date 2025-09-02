pipeline {
    agent any

    environment {
        ARM_TENANT_ID     = credentials('ARM_TENANT_ID')
        ARM_SUBSCRIPTION_ID = credentials('ARM_SUBSCRIPTION_ID')
        ARM_CLIENT_ID     = credentials('ARM_CLIENT_ID')
        ARM_CLIENT_SECRET = credentials('ARM_CLIENT_SECRET')
    }

    stages {
        stage('Add GitHub to known_hosts') {
            steps {
                sh '''
                    mkdir -p /var/jenkins_home/.ssh
                    ssh-keyscan github.com >> /var/jenkins_home/.ssh/known_hosts
                    chmod 644 /var/jenkins_home/.ssh/known_hosts
                '''
            }
        }

        stage('Checkout Code from GitHub') {
            steps {
                git branch: 'main',
                    url: 'git@github.com:pmathpal1/test-repo1.git',
                    credentialsId: 'gitHub-ssh'
            }
        }

        stage('Install Terraform if missing') {
            steps {
                sh '''
                    if ! command -v terraform &> /dev/null
                    then
                        echo "🚀 Installing Terraform..."
                        apt-get update && apt-get install -y wget unzip
                        wget -q https://releases.hashicorp.com/terraform/1.9.5/terraform_1.9.5_linux_amd64.zip
                        unzip terraform_1.9.5_linux_amd64.zip
                        mv terraform /usr/local/bin/
                        terraform -v
                    else
                        echo "✅ Terraform already installed: $(terraform -v)"
                    fi
                '''
            }
        }

        stage('Terraform Format & Validate') {
            steps {
                dir('terraform/main') {
                    sh 'terraform fmt -check'
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Init with Remote Backend') {
            steps {
                dir('terraform/main') {
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform/main') {
                    sh 'terraform plan -input=false'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform/main') {
                    sh 'terraform apply -auto-approve -input=false'
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                dir('terraform/main') {
                    sh 'terraform destroy -auto-approve -input=false'
                }
            }
        }
    }

    post {
        success {
            echo "✅ Terraform pipeline completed successfully!"
        }
        failure {
            echo "❌ Terraform pipeline failed!"
        }
    }
}

pipeline {
    agent any

    environment {
        ARM_TENANT_ID     = credentials('azure-tenant-id')
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        ARM_CLIENT_ID     = credentials('azure-client-id')
        ARM_CLIENT_SECRET = credentials('azure-client-secret')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'git@github.com:pmathpal1/test-repo1.git',
                    credentialsId: 'gitHub-ssh'
            }
        }

        stage('Install Terraform') {
            steps {
                sh '''
                if ! command -v terraform &> /dev/null
                then
                    echo "⚙️ Installing Terraform..."
                    apt-get update && apt-get install -y wget unzip
                    wget -q https://releases.hashicorp.com/terraform/1.9.5/terraform_1.9.5_linux_amd64.zip
                    unzip -o terraform_1.9.5_linux_amd64.zip
                    mv terraform /usr/local/bin/
                else
                    echo "✅ Terraform already installed."
                fi

                terraform -v
                '''
            }
        }

        stage('Terraform Init & Plan') {
            steps {
                sh '''
                echo "🔑 Using Azure credentials from Jenkins"
                echo "👉 Running Terraform Init..."
                terraform init
                terraform plan -out=tfplan
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                echo "🚀 Applying Terraform changes..."
                terraform apply -auto-approve tfplan
                '''
            }
        }
    }

    post {
        failure {
            echo "❌ Terraform pipeline failed!"
        }
        success {
            echo "✅ Terraform pipeline completed successfully!"
        }
    }
}

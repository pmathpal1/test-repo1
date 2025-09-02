pipeline {
    agent any

    environment {
        ARM_CLIENT_ID       = credentials('AZURE_CLIENT_ID')
        ARM_CLIENT_SECRET   = credentials('AZURE_CLIENT_SECRET')
        ARM_SUBSCRIPTION_ID = credentials('AZURE_SUBSCRIPTION_ID')
        ARM_TENANT_ID       = credentials('AZURE_TENANT_ID')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-ssh',
                    url: 'git@github.com:pmathpal1/test-repo1.git'
            }
        }

        stage('Terraform Init & Plan') {
            steps {
                sh '''
                echo "🔑 Using Azure credentials from Jenkins"
                echo "👉 Running Terraform Init..."
                terraform init

                echo "👉 Running Terraform Plan..."
                terraform plan \
                  -var "client_id=$ARM_CLIENT_ID" \
                  -var "client_secret=$ARM_CLIENT_SECRET" \
                  -var "subscription_id=$ARM_SUBSCRIPTION_ID" \
                  -var "tenant_id=$ARM_TENANT_ID"
                '''
            }
        }

        stage('Terraform Apply') {
            when {
                expression { return params.APPLY_TERRAFORM == true }
            }
            steps {
                sh '''
                echo "🚀 Applying Terraform changes..."
                terraform apply -auto-approve \
                  -var "client_id=$ARM_CLIENT_ID" \
                  -var "client_secret=$ARM_CLIENT_SECRET" \
                  -var "subscription_id=$ARM_SUBSCRIPTION_ID" \
                  -var "tenant_id=$ARM_TENANT_ID"
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Terraform pipeline succeeded!"
        }
        failure {
            echo "❌ Terraform pipeline failed!"
        }
    }
}

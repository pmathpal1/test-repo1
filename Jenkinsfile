pipeline {
    agent any

    stages {
        stage('Check Azure Credentials') {
            steps {
                withCredentials([
                    string(credentialsId: 'AZURE_TENANT_ID', variable: 'TENANT'),
                    string(credentialsId: 'AZURE_SUBSCRIPTION_ID', variable: 'SUBSCRIPTION'),
                    string(credentialsId: 'AZURE_CLIENT_ID', variable: 'CLIENT'),
                    string(credentialsId: 'AZURE_CLIENT_SECRET', variable: 'SECRET')
                ]) {
                    sh '''
                        echo "✅ Tenant ID: $TENANT"
                        echo "✅ Subscription ID: $SUBSCRIPTION"
                        echo "✅ Client ID: $CLIENT"
                        echo "✅ Client Secret is set (hidden)"
                    '''
                }
            }
        }

        stage('Azure Login') {
            steps {
                withCredentials([
                    string(credentialsId: 'AZURE_TENANT_ID', variable: 'TENANT'),
                    string(credentialsId: 'AZURE_SUBSCRIPTION_ID', variable: 'SUBSCRIPTION'),
                    string(credentialsId: 'AZURE_CLIENT_ID', variable: 'CLIENT'),
                    string(credentialsId: 'AZURE_CLIENT_SECRET', variable: 'SECRET')
                ]) {
                    sh '''
                        az login --service-principal \
                          -u $CLIENT \
                          -p $SECRET \
                          --tenant $TENANT

                        az account set --subscription $SUBSCRIPTION
                        echo "✅ Azure login successful"
                    '''
                }
            }
        }

        stage('Install Terraform') {
            steps {
                sh '''
                    if ! command -v terraform >/dev/null; then
                      echo "⬇️ Installing Terraform..."
                      curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
                      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
                      apt-get update && apt-get install -y terraform
                    else
                      echo "✅ Terraform already installed"
                    fi
                '''
            }
        }

        stage('Terraform Init & Plan') {
            steps {
                sh '''
                    terraform init
                    terraform plan -out=tfplan
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: "Apply Terraform changes?"
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
}

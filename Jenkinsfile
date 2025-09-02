pipeline {
    agent any

    environment {
        TERRAFORM_VERSION = "1.6.10"
    }

    stages {

        stage('Checkout from GitHub') {
            steps {
                sshagent(credentials: ['gitHub-ssh']) {
                    sh '''
                        rm -rf test-repo1
                        git clone git@github.com:pmathpal1/test-repo1.git
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
                        echo "Logging in to Azure..."
                        az login --service-principal \
                          -u $CLIENT \
                          -p $SECRET \
                          --tenant $TENANT
                        az account set --subscription $SUBSCRIPTION
                        az account show
                    '''
                }
            }
        }

        stage('Install Terraform') {
            steps {
                sh '''
                    if ! command -v terraform >/dev/null; then
                        echo "Installing Terraform..."
                        curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
                        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
                        apt-get update && apt-get install -y terraform
                    else
                        echo "Terraform already installed"
                    fi
                '''
            }
        }

        stage('Terraform Init & Plan') {
            steps {
                dir('terraform') { // <-- change to folder with your .tf files
                    sh '''
                        terraform init
                        terraform plan -out=tfplan
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: "Apply Terraform changes?"
                dir('terraform') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished."
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}

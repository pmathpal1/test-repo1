pipeline {
    agent any

    environment {
        TERRAFORM_VERSION = "1.6.10"

        // Azure Service Principal credentials from Jenkins
        ARM_CLIENT_ID       = credentials('AZURE_CLIENT_ID')
        ARM_CLIENT_SECRET   = credentials('AZURE_CLIENT_SECRET')
        ARM_TENANT_ID       = credentials('AZURE_TENANT_ID')
        ARM_SUBSCRIPTION_ID = credentials('AZURE_SUBSCRIPTION_ID')
    }

    stages {

        stage('Checkout from GitHub') {
            steps {
                sshagent(['gitHub-ssh']) {
                    sh '''
                        rm -rf test-repo1
                        git clone git@github.com:pmathpal1/test-repo1.git
                    '''
                }
            }
        }

        stage('Azure Login') {
            steps {
                sh '''
                    echo "Logging in to Azure..."
                    az login --service-principal \
                        -u $ARM_CLIENT_ID \
                        -p $ARM_CLIENT_SECRET \
                        --tenant $ARM_TENANT_ID

                    az account set --subscription $ARM_SUBSCRIPTION_ID
                    az account show
                '''
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

        stage('Terraform Bootstrap Init & Apply') {
            steps {
                dir("test-repo1/terraform/bootstrap") {
                    sh '''
                        terraform init
                        terraform apply -auto-approve -var subscription_id=$ARM_SUBSCRIPTION_ID
                    '''
                }
            }
        }

        stage('Terraform Main Init & Plan') {
            steps {
                dir("test-repo1/terraform/main") {
                    sh '''
                        terraform init
                        terraform plan -out=tfplan -var subscription_id=$ARM_SUBSCRIPTION_ID
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: "Apply Terraform main changes?"
                dir("test-repo1/terraform/main") {
                    sh '''
                        terraform apply -auto-approve tfplan
                    '''
                }
            }
        }
        /*
        stage('Terraform Destroy') {
            steps {
                input message: "Destroy all Terraform-managed resources?"
                dir("test-repo1/terraform/main") {
                    sh '''
                        terraform destroy -auto-approve
                    '''
                }
            }
        }
        */
    }

    post {
        always { echo "Pipeline finished." }
        success { echo "Pipeline completed successfully!" }
        failure { echo "Pipeline failed!" }
    }
}

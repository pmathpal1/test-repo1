pipeline {
    agent any

    environment {
        TERRAFORM_VERSION = "1.6.10"

        // Azure Service Principal credentials pulled from Jenkins
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
                    az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
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
                script {
                    def tfDir = 'test-repo1/terraform/bootstrap'
                    dir(tfDir) {
                        sh '''
                            terraform init
                            terraform plan -out=tfplan -var-file=terraform.tfvars
                            terraform apply -auto-approve -var-file=terraform.tfvars tfplan
                        '''
                    }
                    env.TF_DIR_BOOTSTRAP = tfDir
                }
            }
        }

        stage('Terraform Main Init & Apply') {
            steps {
                script {
                    def tfDir = 'test-repo1/terraform/main'
                    dir(tfDir) {
                        sh '''
                            terraform init
                            terraform plan -out=tfplan -var-file=terraform.tfvars
                            terraform apply -auto-approve -var-file=terraform.tfvars tfplan
                        '''
                    }
                    env.TF_DIR_MAIN = tfDir
                }
            }
        }
    }

    post {
        always { echo "Pipeline finished." }
        success { echo "Pipeline completed successfully!" }
        failure { echo "Pipeline failed!" }
    }
}

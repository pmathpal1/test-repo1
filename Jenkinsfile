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
        stage('Checkout') {
            steps {
                sshagent(['gitHub-ssh']) {
                    sh '''
                        rm -rf repo-root
                        git clone git@github.com:pmathpal1/test-repo1.git repo-root
                    '''
                }
            }
        }

        stage('Azure Login') {
            steps {
                sh '''
                    az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
                    az account set --subscription $ARM_SUBSCRIPTION_ID
                '''
            }
        }

        stage('Install Terraform') {
            steps {
                sh '''
                    if ! command -v terraform >/dev/null; then
                        curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
                        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
                        apt-get update && apt-get install -y terraform
                    fi
                '''
            }
        }

        stage('Terraform Bootstrap') {
            steps {
                dir('repo-root/terraform/bootstrap') {
                    sh '''
                        terraform init
                        terraform plan -out=tfplan -var "subscription_id=$ARM_SUBSCRIPTION_ID" -var-file="terraform.tfvars"
                        terraform apply -auto-approve -var "subscription_id=$ARM_SUBSCRIPTION_ID" -var-file="terraform.tfvars" tfplan
                    '''
                }
            }
        }

        stage('Terraform Main') {
            steps {
                dir('repo-root/terraform/main') {
                    sh '''
                        terraform init
                        terraform plan -out=tfplan -var "subscription_id=$ARM_SUBSCRIPTION_ID" -var-file="terraform.tfvars"
                        terraform apply -auto-approve -var "subscription_id=$ARM_SUBSCRIPTION_ID" -var-file="terraform.tfvars" tfplan
                    '''
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                input message: "Destroy all Terraform-managed resources?"
                script {
                    // Destroy main first, then bootstrap
                    dir('repo-root/terraform/main') { sh 'terraform destroy -auto-approve -var "subscription_id=$ARM_SUBSCRIPTION_ID" -var-file="terraform.tfvars"' }
                    dir('repo-root/terraform/bootstrap') { sh 'terraform destroy -auto-approve -var "subscription_id=$ARM_SUBSCRIPTION_ID" -var-file="terraform.tfvars"' }
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

pipeline {
    agent any

    stages {
        stage('Terraform Bootstrap Init & Apply') {
            steps {
                dir('terraform/bootstrap') {
                    withCredentials([
                        string(credentialsId: 'ARM_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID'),
                        string(credentialsId: 'ARM_TENANT_ID', variable: 'ARM_TENANT_ID'),
                        string(credentialsId: 'ARM_CLIENT_ID', variable: 'ARM_CLIENT_ID'),
                        string(credentialsId: 'ARM_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET')
                    ]) {
                        sh """
                          terraform init
                          terraform plan -out=tfplan \
                            -var "subscription_id=$ARM_SUBSCRIPTION_ID" \
                            -var "tenant_id=$ARM_TENANT_ID" \
                            -var "client_id=$ARM_CLIENT_ID" \
                            -var "client_secret=$ARM_CLIENT_SECRET" \
                            -var-file=terraform.tfvars
                          terraform apply -auto-approve tfplan
                        """
                    }
                }
            }
        }

        stage('Terraform Main Init & Apply') {
            steps {
                dir('terraform/main') {
                    withCredentials([
                        string(credentialsId: 'ARM_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID'),
                        string(credentialsId: 'ARM_TENANT_ID', variable: 'ARM_TENANT_ID'),
                        string(credentialsId: 'ARM_CLIENT_ID', variable: 'ARM_CLIENT_ID'),
                        string(credentialsId: 'ARM_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET')
                    ]) {
                        sh """
                          terraform init
                          terraform plan -out=tfplan \
                            -var "subscription_id=$ARM_SUBSCRIPTION_ID" \
                            -var "tenant_id=$ARM_TENANT_ID" \
                            -var "client_id=$ARM_CLIENT_ID" \
                            -var "client_secret=$ARM_CLIENT_SECRET" \
                            -var-file=terraform.tfvars
                          terraform apply -auto-approve tfplan
                        """
                    }
                }
            }
        }
    }
}

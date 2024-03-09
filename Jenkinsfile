//change id is not null only if it is a pull request
def isPullRequest = env.CHANGE_ID != null

def environmentVar
if (env.CHANGE_TARGET == "dev" || env.BRANCH_NAME == "dev") {
    environmentVar = "dev"
} else if (env.CHANGE_TARGET == "qa" || env.BRANCH_NAME == "qa") {
    environmentVar = "qa"
} else if (env.CHANGE_TARGET == "main" || env.BRANCH_NAME == "main") {
    environmentVar = "main"
}

def getTestAgent(String testProfile){
    if (testProfile == 'HSQLDB' || testProfile == 'PGSQL' || testProfile == 'MYSQL' || testProfile == 'MARIADB') {
        return """
        agent{
            kubernetes {
                yamlFile 'podTemplate.${testProfile.toLowerCase()}.yaml'
            }
        }
        """
    } else {
        error "Unsupported test profile: ${testProfile}"
    }
}

pipeline {

    agent {
        kubernetes {
            yamlFile 'podTemplate.yaml' 
        }
    }

    environment {
        REPO_URL = "https://github.com/Onadelyer/lavagna.git"
        NETWORK_NAME = "${env.JOB_NAME.toLowerCase().replace('/', '_')}_lavagna"
        IMAGE_NAME = "lavagna-build"
    }

    stages {
        stage('Build app image') {
            // when {
            //     allOf {expression{isPullRequest == true}}
            // }
            steps {
                container('docker-builder'){
                    script {
                        echo "Building Docker image: ${env.IMAGE_NAME}"

                        docker.build("${env.IMAGE_NAME}", "-f Dockerfile.build .")

                        echo "Successfully built ${env.IMAGE_NAME}"

                        docker.withRegistry('http://registry.kube-system.svc.cluster.local:80') {
                            docker.image("${env.IMAGE_NAME}").push()
                        }
                    }
                }
            }
        }
        
        // stage("All db tests") {
        //     // when {
        //     //     allOf {
        //     //         anyOf {
        //     //             expression { env.CHANGE_TARGET == 'main' }
        //     //             expression { env.CHANGE_TARGET == 'qa' }
        //     //         }
        //     //         expression { isPullRequest == true }
        //     //     }
        //     // }
        //     matrix {
        //         axes {
        //             axis {
        //                 name "TEST_PROFILE"
        //                 values 'HSQLDB', 'PGSQL', 'MYSQL', 'MARIADB'
        //             }
        //         }
        //         stages {
        //             stage('Test') {
        //                 agent {
        //                     kubernetes {
        //                         // Dynamically selecting the YAML based on TEST_PROFILE
        //                         yamlFile "podTemplate.${env.TEST_PROFILE.toLowerCase()}.yaml"
        //                     }
        //                 }
        //                 steps {
        //                     container('pod-test'){
        //                         sh "mvn -Ddatasource.dialect=${TEST_PROFILE} -B test"
        //                     }
        //                 }
        //             }
        //         }
        //     }
        // }

        stage('Deploy to K8S'){
            // when {
            //     allOf {expression{isPullRequest == false}}
            // }
            steps{
                container('kubectl-deploy'){
                    script{
                        withCredentials([
                            [$class: 'VaultStringCredentialBinding', credentialsId: 'vault-db-user', variable: 'DB_USER'],
                            [$class: 'VaultStringCredentialBinding', credentialsId: 'vault-db-password', variable: 'DB_PASSWORD']]) {
                            
                            withKubeConfig(caCertificate: '', clusterName: 'minikube', 
                                contextName: 'minikube', 
                                credentialsId: 'kubernetes-token', 
                                namespace: 'jenkins', 
                                restrictKubeConfigAccess: false, serverUrl: 'https://192.168.49.2:8443') {

                                sh "helm upgrade --install myapp ./k8s --set image.tag=${env.BUILD_NUMBER},db.username=${DB_USER},db.password=${DB_PASSWORD},app.name=${environmentVar}"
                            }
                        }
                    }
                }
            }
        }
    }
}
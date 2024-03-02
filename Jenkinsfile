//change id is not null only if it is a pull request
def isPullRequest = env.CHANGE_ID != null

def environmentVars
if (env.CHANGE_TARGET == "dev" || env.BRANCH_NAME == "dev") {
    environmentVars = "dev"
} else if (env.CHANGE_TARGET == "qa" || env.BRANCH_NAME == "qa") {
    environmentVars = "qa"
} else if (env.CHANGE_TARGET == "main" || env.BRANCH_NAME == "main") {
    environmentVars = "main"
}

pipeline {
    // agent { label "${agentLabel}" }

    agent {
        kubernetes {
            yamlFile 'podTemplate.yaml' 
        }
    }
    environment {
        REPO_URL = "https://github.com/Onadelyer/lavagna.git"
        NETWORK_NAME = "${env.JOB_NAME.toLowerCase().replace('/', '_')}_lavagna"
        IMAGE_NAME = "lavagna-build:${env.BUILD_NUMBER}"
    }

    stages {
        // stage('Build app image') {
        //     // when {
        //     //     allOf {expression{isPullRequest == true}}
        //     // }
        //     steps {
        //         container('docker-builder'){
        //             script {
        //                 echo "Building Docker image: ${env.IMAGE_NAME}"

        //                 def builtImage = docker.build("${env.IMAGE_NAME}", "-f Dockerfile.build .")

        //                 echo "Successfully built ${env.IMAGE_NAME}"

        //                 docker.withRegistry('http://docker-registry:5000') {
        //                     docker.image("${env.IMAGE_NAME}").push()
        //                 }
        //             }
        //         }
        //     }
        // }
        
        stage('Deploy to K8S'){
            steps{
                container('kubectl-deploy'){
                    script{
                        withKubeConfig(caCertificate: '', clusterName: 'minikube', contextName: 'minikube', credentialsId: 'c8e3e0db-7d5c-48e7-8012-16ae6273dfbe', namespace: 'jenkins', restrictKubeConfigAccess: false, serverUrl: 'https://192.168.49.2:8443') {
                            sh 'kubectl get ns'
                            sh "helm upgrade --install myapp ./test-chart"
                            //sh 'helm ls'
                        }
                    }
                }
            }
        }
        
        // stage('Up test db services'){
        //     when{
        //         allOf{expression{isPullRequest == true}}
        //     }
        //     steps{
        //         step([$class: 'DockerComposeBuilder', dockerComposeFile: 'docker-compose.dbstart.yml', option: [$class: 'StartAllServices'], useCustomDockerComposeFile: true])
        //     }
        // }

        // stage("All db tests") {
        //     when{
        //         allOf{
        //             anyOf{
        //                 expression{env.CHANGE_TARGET == 'main'}
        //                 expression{env.CHANGE_TARGET == 'qa'}
        //             }
        //             expression{isPullRequest == true}
        //         }
        //     }
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
        //                     docker {
        //                         label "${agentLabel}"
        //                         image "lavagna-build:${env.BUILD_NUMBER}"
        //                         args "--network ${NETWORK_NAME}"
        //                     }
        //                 }
        //                 steps {
        //                     sh "mvn -Ddatasource.dialect=${TEST_PROFILE} -B test"
        //                 }
        //             }
        //         }
        //     }
        // }

        // stage("Single db tests") {
        //     when{
        //         allOf{
        //             anyOf{
        //                 expression{env.CHANGE_TARGET == 'dev'}
        //             }
        //             expression{isPullRequest == true}
        //         }
        //     }
        //     matrix {
        //         axes {
        //             axis {
        //                 name "TEST_PROFILE"
        //                 values 'HSQLDB'
        //             }
        //         }
        //         stages {
        //             stage('Test') {
        //                 agent {
        //                     docker {
        //                         label "${agentLabel}"
        //                         image "lavagna-build:${env.BUILD_NUMBER}"
        //                         args "--network ${NETWORK_NAME}"
        //                     }
        //                 }
        //                 steps {
        //                     sh "mvn -Ddatasource.dialect=${TEST_PROFILE} -B test"
        //                 }
        //             }
        //         }
        //     }
        // }

        // stage('Down previous deployment'){
        //     when{
        //         allOf{expression{isPullRequest == false}}
        //     }
        //     steps{
        //         script {
        //             sh 'docker-compose -f docker-compose.deploy.yml down'
        //             sh 'docker-compose -f docker-compose.deploy.yml rm'
        //         }
        //     }
        // }

        // stage('Deploy'){
        //     when{
        //         allOf{
        //             expression{isPullRequest == false}
        //         }
        //     }
        //     steps{
        //         script {
        //             sh "sed -i 's/FROM .*/FROM lavagna-build:${BUILD_NUMBER}/' Dockerfile.deploy"
        //         }
        //         withVault(configuration: [disableChildPoliciesOverride: false, timeout: 60, vaultCredentialId: 'vault-jenkins-role', vaultUrl: 'http://10.26.0.208:8200'], 
        //         vaultSecrets: [
        //         [path: 'secrets/creds/lavagna-secret-text', secretValues: [[vaultKey: 'DB_URL'], [vaultKey: 'DB_NAME'], [vaultKey: 'DB_USER'], [vaultKey: 'DB_PASSWORD'], [vaultKey: 'DB_DIALECT']]], 
        //         [path: 'secrets/creds/datadog-credentials', secretValues: [[vaultKey: 'DATADOG_API_KEY'], [vaultKey: 'DATADOG_SITE']]]
        //         ]) {
                    
        //             sh 'echo "DB_URL=${DB_URL}" > .env'
        //             sh 'echo "DB_NAME=${DB_NAME}" >> .env'
        //             sh 'echo "DB_USER=${DB_USER}" >> .env'
        //             sh 'echo "DB_PASSWORD=${DB_PASSWORD}" >> .env'
        //             sh 'echo "DB_DIALECT=${DB_DIALECT}" >> .env'
        //             sh 'echo "DATADOG_API_KEY=${DATADOG_API_KEY}" >> .env'
        //             sh 'echo "DATADOG_SITE=${DATADOG_SITE}" >> .env'

        //             step([$class: 'DockerComposeBuilder', dockerComposeFile: 'docker-compose.deploy.yml', option: [$class: 'StartAllServices'], useCustomDockerComposeFile: true])
        //         }
        //     }
        // }

        // stage('Push image to registry'){
        //     when{
        //         allOf{expression{isPullRequest == false}}
        //     }
        //     steps{
        //         script{
        //             docker.withRegistry('http://10.26.0.176:5000') {
        //                 docker.image("lavagna-build:${env.BUILD_NUMBER}").push()
        //             }
        //         }
        //     }
        // }
    }
}
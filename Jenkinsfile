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
            yaml '''
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: docker
                image: docker:latest
                command:
                - cat
                tty: true  
            '''
        }
    }
    
    environment {
        REPO_URL = "https://github.com/Onadelyer/lavagna.git"
        NETWORK_NAME = "${env.JOB_NAME.toLowerCase().replace('/', '_')}_lavagna"
        IMAGE_NAME = "lavagna-build:${env.BUILD_NUMBER}"
    }

    stages {
        stage('Clone'){
            steps{
                container('docker'){
                    git branch: "${environmentVars}", changelog: false, poll: false, url: "${env.REPO_URL}"
                }
            }
        }

        stage('Build app image') {
            // when {
            //     allOf {expression{isPullRequest == true}}
            // }
            steps {
                container('docker'){
                    script {
                        echo "Building Docker image: ${env.IMAGE_NAME}"
                        
                        def builtImage = docker.build("${env.IMAGE_NAME}", "-f Dockerfile.build .")
                        
                        echo "Successfully built ${env.IMAGE_NAME}"

                        docker.withRegistry('http://registry.docker-registry.svc.cluster.local:5000') {
                            docker.image("${env.IMAGE_NAME}").push()
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
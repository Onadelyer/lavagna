//change id is not null only if it is a pull request
def isPullRequest = env.CHANGE_ID != null

def agentLabel
if (env.CHANGE_TARGET == "dev" || env.BRANCH_NAME == "dev") {
    agentLabel = "dev"
} else if (env.CHANGE_TARGET == "qa" || env.BRANCH_NAME == "qa") {
    agentLabel = "qa"
} else if (env.CHANGE_TARGET == "main" || env.BRANCH_NAME == "main") {
    agentLabel = "main"
}

def testProfiles = []
if (env.CHANGE_TARGET == 'main') {
    testProfiles = ["HSQLDB", "PGSQL", "MYSQL", "MARIADB"]
} else if (env.CHANGE_TARGET == 'qa') {
    testProfiles = ["HSQLDB", "PGSQL", "MYSQL", "MARIADB"]
} else if (env.CHANGE_TARGET == 'dev') {
    testProfiles = ["HSQLDB"]
}

pipeline {
    agent { label "${agentLabel}" }
    
    environment {
        NETWORK_NAME = "${env.JOB_NAME.toLowerCase().replace('/', '_')}_lavagna"
    }

    stages {
        stage('Build app image'){
            when{
                allOf{
                    expression{isPullRequest == false}
                }
            }
            steps {
                script{
                    docker.build("lavagna-build:${env.BUILD_NUMBER}", "-f Dockerfile.build .")
                }
            }
        }

        stage('Up test db services'){
            when{
                allOf{
                    expression{isPullRequest == true}
                }
            }
            steps{
                step([$class: 'DockerComposeBuilder', dockerComposeFile: 'docker-compose.dbstart.yml', option: [$class: 'StartAllServices'], useCustomDockerComposeFile: true])
            }
        }

        stage("All db tests") {
            when{
                allOf{
                    anyOf{
                        expression{env.CHANGE_TARGET == 'main'}
                        expression{env.CHANGE_TARGET == 'qa'}
                    }
                    expression{isPullRequest == true}
                }
            }
            matrix {
                axes {
                    axis {
                        name "TEST_PROFILE"
                        values 'HSQLDB', 'PGSQL', 'MYSQL', 'MARIADB'
                    }
                }
                stages {
                    stage('Test') {
                        agent {
                            docker {
                                label "${agentLabel}"
                                image 'maven:3.8.6-openjdk-8'
                                args "--network ${NETWORK_NAME}"
                            }
                        }
                        steps {
                            sh "mvn -Ddatasource.dialect=${TEST_PROFILE} -B test --file pom.xml"
                        }
                    }
                }
            }
        }

        stage("Single db test") {
            when{
                allOf{
                    anyOf{
                        expression{env.CHANGE_TARGET == 'dev'}
                    }
                    expression{isPullRequest == true}
                }
            }
            matrix {
                axes {
                    axis {
                        name "TEST_PROFILE"
                        values 'HSQLDB'
                    }
                }
                stages {
                    stage('Test') {
                        agent {
                            docker {
                                label "${agentLabel}"
                                image '10.26.0.176:5000/maven:3.8.6-openjdk-8'
                                args "--network ${NETWORK_NAME}"
                            }
                        }
                        steps {
                            sh "mvn -Ddatasource.dialect=${TEST_PROFILE} -B test --file pom.xml"
                        }
                    }
                }
            }
        }

        stage('Down previous deployment'){
            when{
                allOf{
                    expression{isPullRequest == false}
                }
            }
            steps{
                script {
                    sh 'docker-compose -f docker-compose.deploy.yml rm'
                }
            }
        }

        stage('Deploy'){
            when{
                allOf{
                    expression{isPullRequest == false}
                }
            }
            steps{
                script {
                    sh "sed -i 's/FROM .*/FROM lavagna-build:${BUILD_NUMBER}/' Dockerfile.deploy"
                }
                // withVault(configuration: [disableChildPoliciesOverride: false, timeout: 60, vaultCredentialId: 'vault-jenkins-role', vaultUrl: 'http://10.26.0.208:8200'], 
                // vaultSecrets: [
                // [path: 'secrets/creds/lavagna-secret-text', secretValues: [[vaultKey: 'DB_URL'], [vaultKey: 'DB_NAME'], [vaultKey: 'DB_USER'], [vaultKey: 'DB_PASSWORD'], [vaultKey: 'DB_DIALECT']]], 
                // [path: 'secrets/creds/datadog-credentials', secretValues: [[vaultKey: 'DATADOG_API_KEY'], [vaultKey: 'DATADOG_SITE']]]]) {
                sh "printenv"
                step([$class: 'DockerComposeBuilder', dockerComposeFile: 'docker-compose.deploy.yml', option: [$class: 'StartAllServices'], useCustomDockerComposeFile: true])
                // }
            }
        }
    }
    post {
        always {
            script {
                if (isPullRequest == true) {
                    sh 'docker-compose -f docker-compose.dbstart.yml down -v'
                }
            }
        }
    }
}
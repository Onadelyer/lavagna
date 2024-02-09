//change id is not null only if it is a pull request
def isPullRequest = env.CHANGE_ID != null

def agentLabel
if (env.CHANGE_TARGET == "dev") {
    agentLabel = "dev"
} else if (env.CHANGE_TARGET == "qa") {
    agentLabel = "qa"
} else if (env.CHANGE_TARGET == "main") {
    agentLabel = "main"
}

def testProfiles = []
if (env.CHANGE_TARGET == 'main') {
    testProfiles = ["HSQLDB", "PGSQL", "MYSQL", "MARIADB"]
} else if (env.CHANGE_TARGET == 'dev') {
    testProfiles = ["HSQLDB"]
} else if (env.CHANGE_TARGET == 'qa') {
    testProfiles = ["HSQLDB", "PGSQL", "MYSQL", "MARIADB"]
}

pipeline {
    agent { label "${agentLabel}" }
    
    environment {
        NETWORK_NAME = "${env.JOB_NAME.toLowerCase().replace('/', '_')}_lavagna"
    }

    stages {
        stage('Clear environment') {
            steps {
                sh "echo ${env.NETWORK_NAME}"
                sh "echo ${env.CHANGE_TARGET}"
                sh 'chmod +x ./clear-environment.sh'
                sh './clear-environment.sh'
            }
        }

        stage('Build app image'){
            when{
                allOf{
                    expression{isPullRequest == false}
                }
            }
            steps {
                script{
                    docker.build("lavagna-build", "-f Dockerfile.build .")
                }
            }
        }

        stage('Setup test databases'){
            when{
                allOf{
                    expression{isPullRequest == true}
                }
            }
            steps{
                step([$class: 'DockerComposeBuilder', dockerComposeFile: 'docker-compose.dbstart.yml', option: [$class: 'StartAllServices'], useCustomDockerComposeFile: true])
            }
        }

        stage("Execute all db tests") {
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

        stage("Execute single db tests") {
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

        stage('Deploy'){
            when{
                allOf{
                    expression{isPullRequest == false}
                }
            }
            steps{
                step([$class: 'DockerComposeBuilder', dockerComposeFile: 'docker-compose.deploy.yml', option: [$class: 'StartAllServices'], useCustomDockerComposeFile: true])
            }
        }
    }
    post {
        script {
            if (isPullRequest == true)
                step([$class: 'DockerComposeBuilder', dockerComposeFile: 'docker-compose.dbstart.yml', option: [$class: 'StopAllServices'], useCustomDockerComposeFile: true])
        }
    }
}

def agentLabel
if (env.CHANGE_TARGET == "dev") {
    agentLabel = "dev"
}
if (env.CHANGE_TARGET == "qa") {
    agentLabel = "qa"
}
if (env.CHANGE_TARGET == "main") {
    agentLabel = "main"
}


pipeline {
    agent { label "${env.CHANGE_TARGET} ${agentLabel} oracle" }
    
    environment {
        NETWORK_NAME = "${env.JOB_NAME.toLowerCase().replace('/', '_')}_lavagna"
    }

    stages {
        stage('Clear environment') {
            steps {
                sh 'chmod +x ./clear-environment.sh'
                sh './clear-environment.sh'
            }
        }

        // stage('Build app image'){
        //     steps {
        //         script{
        //             docker.build("lavagna-build", "-f Dockerfile.build .")
        //         }
        //     }
        // }

        stage('Setup test databases'){
            steps{
                step([$class: 'DockerComposeBuilder', dockerComposeFile: 'docker-compose.dbstart.yml', option: [$class: 'StartAllServices'], useCustomDockerComposeFile: true])
            }
        }

        stage("Execute tests") {
            steps{
                script{
                    def testProfiles = []

                    if (env.BRANCH_NAME == 'main') {
                        matrixValues = ["HSQLDB", "PGSQL", "MYSQL", "MARIADB"]
                    } else if (env.BRANCH_NAME == 'dev') {
                        matrixValues = ["HSQLDB"]
                    } else if (env.BRANCH_NAME == 'qa') {
                        matrixValues = ["HSQLDB", "PGSQL", "MYSQL", "MARIADB"]
                    }

                    matrix {
                        axes {
                            axis {
                                name "TEST_PROFILE"
                                values testProfiles
                            }
                        }
                        stages {
                            stage('Test') {
                                agent {
                                    docker {
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
            }
        }


        // stage('Build HSQLDB') {
        //     agent {
        //         docker {
        //             image 'maven:3.8.3-jdk-8'
        //         }
        //     }
        //     steps {
        //         checkout scm
        //         sh 'mvn -v'
        //         sh 'mvn -Ddatasource.dialect=HSQLDB -B package --file pom.xml'
        //     }
        // }
        
        // stage('Build PGSQL 9.4') {
        //     agent {
        //         docker {
        //             image 'maven:3.8.3-jdk-8'
        //             args '--network lavagna-pipeline_lavagna'
        //         }
        //     }
        //     steps {
        //         sh 'mvn -v'
        //         sh 'mvn -Ddatasource.dialect=PGSQL -B package --file pom.xml'
        //     }
        // }
        
        // stage('Build MYSQL') {
        //     agent {
        //         docker {
        //             image 'maven:3.8.3-jdk-8'
        //             args '--network lavagna-pipeline_lavagna --memory 4g'
        //         }
        //     }
        //     steps {
        //         sh 'mvn -v'
        //         sh 'mvn -Ddatasource.dialect=MYSQL -B package --file pom.xml'
        //     }
        // }
        
        // stage('Build MARIADB') {
        //     agent {
        //         docker {
        //             image 'maven:3.8.3-jdk-8'
        //             args '--network lavagna-pipeline_lavagna --memory 4g'
        //         }
        //     }
        //     steps {
        //         sh 'mvn -v'
        //         sh 'mvn -Ddatasource.dialect=MARIADB -B package --file pom.xml'
        //     }
        // }
    }
    post {
        always {
            step([$class: 'DockerComposeBuilder', dockerComposeFile: 'docker-compose.dbstart.yml', option: [$class: 'StopAllServices'], useCustomDockerComposeFile: true])
        }
    }
}

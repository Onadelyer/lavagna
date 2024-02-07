pipeline {
    agent any
    
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
            matrix {
                axes {
                    axis {
                        name "TEST_PROFILE"
                        values "HSQLDB", "PGSQL", "MYSQL", "MARIADB"
                    }
                }
                stages {
                    stage('Test') {
                        agent {
                            docker {
                                image 'maven:3.8.6-openjdk-8'
                                args '--network lavagna'
                            }
                        }
                        steps {
                            sh "mvn -Ddatasource.dialect=${TEST_PROFILE} -B test --file pom.xml"
                        }
                    }
                }
            }
        }

        // stage('Down test databases'){
        //     steps{
        //         step([$class: 'DockerComposeBuilder', dockerComposeFile: 'docker-compose.dbstart.yml', option: [$class: 'StopAllServices'], useCustomDockerComposeFile: true])
        //     }
        // }


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
}

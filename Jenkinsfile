def isPullRequest = env.CHANGE_ID != null

pipeline {
    agent {
        kubernetes {
            yamlFile 'jenkins_agent_templates/podTemplate.yaml'
        }
    }
    environment {
        IMAGE_NAME = "lavagna-build"
    }
    stages {
        stage('Build app image') {
            when {
                allOf {expression{isPullRequest == true}}
            }
            steps {
                container('docker-builder'){
                    script {
                        def buildImage = docker.build("${env.IMAGE_NAME}", "-f Dockerfile.build .")

                        buildImage.inside('-v $WORKSPACE:/output -u root'){
                            sh "pwd"
                            sh "ls"
                            sh "cp lavagna-jetty-console.war /output/ROOT.war"
                        }
                        sh "ls"
                        // docker.withRegistry('http://registry.kube-system.svc.cluster.local:80') {
                        //     docker.image("${env.IMAGE_NAME}").push()
                        // }
                    }
                }
            }
        }
        
        // stage("All db tests") {
        //     when {
        //         allOf {
        //             anyOf {
        //                 expression { env.CHANGE_TARGET == 'main' }
        //                 expression { env.CHANGE_TARGET == 'qa' }
        //             }
        //             expression { isPullRequest == true }
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
        //                     kubernetes {
        //                         yamlFile "jenkins_agent_templates/podTemplate.${env.TEST_PROFILE.toLowerCase()}.yaml"
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
            when {
                allOf {expression{isPullRequest == false}}
            }
            steps{
                container('kubectl-deploy'){
                    script{
                        withCredentials([
                            [$class: 'VaultStringCredentialBinding', credentialsId: 'vault-db-user', variable: 'DB_USER'],
                            [$class: 'VaultStringCredentialBinding', credentialsId: 'vault-db-password', variable: 'DB_PASSWORD']]) {
                            
                            withKubeConfig(caCertificate: '', clusterName: 'minikube', 
                                contextName: 'minikube', 
                                credentialsId: 'kubernetes-serviceaccount', 
                                namespace: 'jenkins', 
                                restrictKubeConfigAccess: false, serverUrl: 'https://kubernetes.default.svc') {

                                sh "helm upgrade --install myapp ./k8s --set image.tag=${env.BUILD_NUMBER},db.username=${DB_USER},db.password=${DB_PASSWORD},app.name=${env.BRANCH_NAME}"
                            }
                        }
                    }
                }
            }
        }
        
    }
}
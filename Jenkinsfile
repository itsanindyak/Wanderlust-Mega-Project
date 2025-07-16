@Library('Shared') _
pipeline {
    agent {label 'Node'}

    environment{
        SONAR_SCANNER_HOME = tool "sonar"
    }

    parameters {
        string(name: 'FRONTEND_DOCKER_TAG', defaultValue: '', description: 'Setting docker image for latest push')
        string(name: 'BACKEND_DOCKER_TAG', defaultValue: '', description: 'Setting docker image for latest push')
    }

    stages {
        stage("Validate Parameters") {
            steps {
                script {
                    if (params.FRONTEND_DOCKER_TAG == '' || params.BACKEND_DOCKER_TAG == '') {
                        error("FRONTEND_DOCKER_TAG and BACKEND_DOCKER_TAG must be provided.")
                    }
                }
            }
        }
        stage("Workspace cleanup"){
            steps{
                script{
                    cleanWs()
                }
            }
        }

        stage('Git: Code Checkout') {
            steps {
                script{
                    clone("https://github.com/itsanindyak/Wanderlust-Mega-Project.git","main")
                }
            }
        }

        stage("Trivy: Filesystem scan"){
            steps{
                script{
                    trivy()
                }
            }
        }

        stage("OWASP: Dependency check"){
            steps{
                script{
                    owasp()
                }
            }
        }

        stage("SonarQube: Code Analysis"){
            steps{
                script{
                    sonarqubeAnalysis("sonar","wanderlust","wanderlust")
                }
            }
        }

        stage("SonarQube: Code Quality Gates"){
            steps{
                script{
                    sonarqubeCodeQuality()
                }
            }
        }

        // stage('Exporting environment variables') {
        //     parallel{
        //         stage("Backend env setup"){
        //             steps {
        //                 script{
        //                     dir("Automations"){
        //                         sh "bash updatebackendnew.sh"
        //                     }
        //                 }
        //             }
        //         }

        //         stage("Frontend env setup"){
        //             steps {
        //                 script{
        //                     dir("Automations"){
        //                         sh "bash updatefrontendnew.sh"
        //                     }
        //                 }
        //             }
        //         }
        //     }
        // }

        stage("Docker: Build Images"){
            steps{
                script{
                        dir('backend'){
                            dockerBuild("wanderlust-backend-beta","${params.BACKEND_DOCKER_TAG}","itsanindyak")
                        }

                        dir('frontend'){
                            dockerBuild("wanderlust-frontend-beta","${params.FRONTEND_DOCKER_TAG}","itsanindyak")
                        }
                }
            }
        }

        stage("Docker: Push to DockerHub"){
            steps{
                script{
                    dockerPush("wanderlust-backend-beta","${params.BACKEND_DOCKER_TAG}","itsanindyak")
                    dockerPush("wanderlust-frontend-beta","${params.FRONTEND_DOCKER_TAG}","itsanindyak")
                }
            }
        }
    }
    post{
        success{
            archiveArtifacts artifacts: '*.xml', followSymlinks: false
            build job: "Wanderlust-CD", parameters: [
                string(name: 'FRONTEND_DOCKER_TAG', value: "${params.FRONTEND_DOCKER_TAG}"),
                string(name: 'BACKEND_DOCKER_TAG', value: "${params.BACKEND_DOCKER_TAG}")
            ]
        }
    }
}
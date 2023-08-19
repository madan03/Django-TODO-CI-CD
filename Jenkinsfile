pipeline{

    agent any

    stage{

        stage('checkout'){
            step{
                sh 'echo passed'
                // git branch 'master' , url: 'https://github.com/madan03/Django-TODO-CI-CD.git'
            }
        }
    }
    
    stages{

        stage('Build and Test') {
            steps {
                sh 'ls -ltr'
        //        sh 'mvn clean package'

                
            }

            post {
                success {
                    script {
                        slackSend(
                        color: '#36a64f',  
                        message: "Build ${env.BUILD_NUMBER} succeeded!",  
                        CredentialId: 'slack-jenkins'  
                        )
                    }
                }
            }
                
        }

        stage("Static Code Analysis"){

            environment {
                SONAR_URL = "https://0b73-2405-201-a405-1893-d587-7c74-d639-3cdb.ngrok-free.app"
                }

            steps{
                echo "========Start Testing========"
                
                withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_AUTH_TOKEN')]) {
                    sh 'mvn sonar:sonar -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.host.url=${SONAR_URL}'
                    
                }

            }

            post {
                success {
                    script {
                        slackSend(
                            color: '#36a64f',  
                            message: "Test of ${env.BUILD_NUMBER} succeeded! using sonarqube",  
                            tokenCredentialId: 'slack-jenkins'  
                        )
                    }
                }

                failure {
                    script {
                        slackSend(
                            color: '#ff0000',
                            message: "Test failed",
                            tokenCredentialId: 'slack-jenkins'
                        )

                    }
                }
            }
        }

        stage("Build docker file and push"){

            environment {
                DOCKER_IMAGE = "2054121/django-todo-cicd:${BUILD_NUMBER}"
                REGISTRY_CREDENTIALS = credentials('docker_hub')
            
            }

            steps{

                script {
                    sh "docker build -t ${DOCKER_IMAGE} ."
                    def dockerImage = docker.image("${DOCKER_IMAGE}")
                    docker.withRegistry("https://index.docker.io/v1/", "docker_hub") {
                        dockerImage.push()
                    }

                    slackSend(
                        color: '#36a64f',  
                        message: "Docker build ${env.BUILD_NUMBER} succeeded!",  
                        tokenCredentialId: 'slack-jenkins'  
                    )
                }
            }
        }

        stage('Update Deployment File') {

            environment {
                GIT_REPO_NAME = "Django-TODO-CI-CD"
                GIT_USER_NAME = "madan03"
            }
        
            steps {
                sh 'echo passed'
                git branch: 'master', url: 'https://github.com/madan03/Django-TODO-CI-CD.git'
                withCredentials([string(credentialsId: 'github-token', variable: 'GITLAB_TOKEN')]) {
                    sh '''
                        git config user.email "pandeyrocky021@gmail.com"
                        git config user.name "madan03"
                        
                        BUILD_NUMBER="${BUILD_NUMBER}"

                        sed -i "s/replaceImageTag/${BUILD_NUMBER}/g" k8s/deployment.yml
                        
                        git add k8s/deployment.yaml
                        
                        git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                        
                        git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:master

                    '''
                    // for GITLAB:->

                   //git push "https://oauth2:${GITLAB_TOKEN}@gitlab.com/${GITLAB_USERNAME}/${GITLAB_PROJECT_NAME}" HEAD:main
                }

                script {
                    slackSend(
                        color: '#36a64f',  
                        message: "Final Build ${env.BUILD_NUMBER} succeeded! and deployment file updated with new version",  
                        tokenCredentialId: 'slack-jenkins'  
                    )
                }
            }
        }
    }
    
}

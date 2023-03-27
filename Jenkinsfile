//@Library('shared-lib') _
library 'shared-lib@main'

pipeline {

  options {

    buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '10', daysToKeepStr: '', numToKeepStr: '10')
    disableConcurrentBuilds()
    timestamps()
    timeout(time: 10, unit: 'MINUTES')
   }

  agent {
    docker {
        image 'jenkins-agent:latest'
        args  '--user root -v /var/run/docker.sock:/var/run/docker.sock'
    }
    }
    environment{
        SNYK_TOKEN = credentials('snyk')
    }

    stages {
        stage('test') {
            parallel{
               stage('pytest'){
                   steps{
                    catchError(message:'pytest ERROR'){
                      withCredentials([file(credentialsId: 'telegramToken', variable: 'TELEGRAM_TOKEN')])
                      {
                       sh "cp ${TELEGRAM_TOKEN} .telegramToken"
                       sh 'pip3 install -r requirements.txt'
                       sh "python3 -m pytest --junitxml results.xml test/*.py"
                      }
                    }
                  }
               }

                stage('pylint'){
                   steps{
                   catchError(message:'pylint ERROR'){
                          script {
                            logs.info 'Starting'
                            logs.warning 'Nothing to do!'
                            sh "python3 -m pylint *.py || true"
                        }
                      }
                   }
               }
            }
        }

        stage('Build') {
            steps {
                sh "docker build -t dariakalugny/polybot-${env.BUILD_NUMBER} . "
              }
            }

       stage('snyk test') {
            steps {
               catchError(message:'snyk ERROR')
               {
                sh "snyk container test dariakalugny/polybot-${env.BUILD_NUMBER} --severity-threshold=high"
               }
             }
           }

        stage('push') {
            steps {
              catchError(message:'push ERROR'){
                withCredentials([usernamePassword(credentialsId: 'dariakalugny-dockerhub', passwordVariable: 'pass', usernameVariable: 'user')])
                {
                 sh "docker login --username $user --password $pass"
                sh "docker push dariakalugny/polybot-${env.BUILD_NUMBER}"
                }
              }
            }
        }
    }
       post{
            always{
               junit allowEmptyResults: true, testResults: 'results.xml'
                sh "docker rmi dariakalugny/polybot-${env.BUILD_NUMBER}"
            }

       }

  }

 
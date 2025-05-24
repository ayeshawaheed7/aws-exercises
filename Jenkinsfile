#!/usr/bin/env groovy

pipeline {

    agent any 

    tools {
        nodejs 'node'
    }

    stages {
        stage ('increment version') {
            steps {
                script {
                    echo 'incrementing the app version...'
                    dir('app') {
                        sh 'npm version patch --no-git-tag-version'

                        def packageJson = readJson 'package.json'
                        def version = packageJson.version
                        env.IMAGE_VERSION = "$version-$BUILD_NUMBER"
                    }
                }
            }
        }
        stage ('run tests') {
            steps {
                script {
                    echo 'running the test cases'
                    dir('app') {
                        sh 'npm install'
                        sh 'npm run test'
                    }
                }
            }
        }
        stage ('build and push docker image') {
            steps {
                script {
                    echo 'building and push docker image...'
                    withCredentials([
                       usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')
                    ]){
                        sh "docker build -t ayeshawaheed12/demo-app:njs-${IMAGE_VERSION} ."
                        sh "echo ${PASS} | docker login -u ${USER} -p --password-stdin"
                        sh "docker push ayeshawaheed12/demo-app:njs-${IMAGE_VERSION}"
                    }
                }
            }
        }
        stage ('deploy on EC2 server') {
            steps {
                script {
                    echo 'deploying app on EC2 server...'
                    def shellCmds = "bash ./shell-cmds.sh ayeshawaheed12/demo-app:njs-${IMAGE_VERSION}"
                    sshagent(['ec2-server-nodejs-app-key']) {
                       sh 'scp shell-cmds.sh ec2-user@54.168.49.98:/home/ec2-user'
                       sh 'scp docker-compose.yaml ec2-user@54.168.49.98:/home/ec2-user'
                       sh "ssh -o StrictHostKeyChecking=no ec2-user@54.168.49.98 ${shellCmds}"
                    }
                }
            }
        }
        stage ('commit updated version') {
            steps {
                script {
                    echo 'committing the updated app version...'
                    withCredentials([
                       usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')
                    ]){
                        sh "git remote set-url origin https://${USER}:${PASS}@github.com/ayeshawaheed7/aws-exercises.git"
                        sh 'git add .'
                        sh 'git commit -m "ci: bump version"'
                        sh 'git push origin HEAD:main'
                    }
                }
            }
        }
    }
}
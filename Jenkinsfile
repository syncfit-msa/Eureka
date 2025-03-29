pipeline {
    agent any

    stages {
        stage('Git clone') {
            steps {
                git branch: 'develop', url: 'https://github.com/syncfit-msa/Eureka.git';
            }
        }

        stage('Project Build') {
            steps {
                sh '''
                    echo build start;
                    ./gradlew clean build -DskipTests=true
                ''';
            }
        }

        stage ('AWS Credential') {
            steps {
                withCredentials([[
                $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'aws-access-key']]) {
                    sh 'aws ecr get-login-password --region ap-northeast-3 | docker login --username AWS --password-stdin 268104899906.dkr.ecr.ap-northeast-3.amazonaws.com'
                }
            }
        }

        stage('Docker Image Build') {
            steps {
                sh '''
                    docker build --platform linux/amd64 -t mini2/eureka .
                    docker tag mini2/eureka:latest 268104899906.dkr.ecr.ap-northeast-3.amazonaws.com/mini2/eureka:latest
                '''
            }
        }

        stage("Push to ECR") {
            steps {
                withCredentials([[
                $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'aws-access-key']]) {
                    sh 'docker push 268104899906.dkr.ecr.ap-northeast-3.amazonaws.com/mini2/eureka:latest'
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-access-key'
                ]]) {
                    sh 'aws ecs update-service --cluster LG-CNS-Mini2-10 --service srv-Eureka --force-new-deployment'
                }
            }
        }

        stage('Cleanup') {
            steps {
                sh 'docker rmi mini2/eureka:latest || true'
                sh 'docker rmi 268104899906.dkr.ecr.ap-northeast-3.amazonaws.com/mini2/eureka:latest || true'
            }
        }
    }
}
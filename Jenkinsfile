pipeline {
    agent any

    stages {
        stage('Check Branch') {
            when {
                branch 'develop'
            }
            steps {
                echo 'Running on develop branch'
            }
        }

        stage('git clone') {
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
                    docker build --platform linux/amd64 -t lg-cns-mini-2-10/eureka .
                    docker tag lg-cns-mini-2-10/eureka:latest 969400486267.dkr.ecr.ap-northeast-3.amazonaws.com/lg-cns-mini-2-10/eureka:latest
                '''
            }
        }

        stage("Push to ECR") {
            when {
                branch 'develop'
            }
            steps {
                withCredentials([[
                $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'aws-access-key']]) {
                    sh 'docker push 969400486267.dkr.ecr.ap-northeast-3.amazonaws.com/lg-cns-mini-2-10/eureka:latest'
                }
            }
        }

        stage('Deploy to ECS') {
            when {
                branch 'develop'
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-access-key'
                ]]) {
                    sh 'aws ecs update-service --cluster LG-CNS-Mini2 --service srv-LG-CNS-Eureka --force-new-deployment'
                }
            }
        }

        stage('Cleanup') {
            steps {
                sh 'docker rmi lg-cns-mini-2-10/eureka:latest || true'
                sh 'docker rmi 969400486267.dkr.ecr.ap-northeast-3.amazonaws.com/lg-cns-mini-2-10/eureka:latest || true'
            }
        }
    }
}
pipeline {

    agent any

    environment {
        APP_IMAGE = "elk-jenkins-lab-app:${BUILD_NUMBER}"
        COMPOSE_PROJECT_NAME = "elk-jenkins-lab"
    }

    stages {

        /* Uncomment to use git repo
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        */
        stage('Python Tests') {
            steps {
                echo 'Running Python tests...'

                sh '''
                    docker run --rm \
                      -v "$PWD/app:/app" \
                      -w /app \
                      python:3.12-slim \
                      sh -c "pip install -q pytest && pytest -v"
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building ${APP_IMAGE}"

                sh """
                    docker build \
                      -t ${APP_IMAGE} \
                      ./app
                """
            }
        }

        stage('Deploy ELK') {
            steps {
                echo 'Starting ELK...'

                sh '''
                    docker compose up -d elasticsearch logstash kibana
                '''
            }
        }

        stage('Generate Logs') {
            steps {
                echo 'Generating logs...'

                sh """
                    docker run --rm \
                      --network ${COMPOSE_PROJECT_NAME}_default \
                      ${APP_IMAGE}
                """
            }
        }

        stage('Verify Elasticsearch') {
            steps {
                echo 'Waiting for Elasticsearch...'

                sh '''
                    sleep 10

                    curl -f \
                      http://elasticsearch:9200/_cluster/health
                '''
            }
        }
    }

    post {

        success {
            echo '================================='
            echo 'PIPELINE SUCCESS'
            echo '================================='
        }

        failure {
            echo '================================='
            echo 'PIPELINE FAILED'
            echo '================================='
        }

        always {
            echo "Build ${BUILD_NUMBER} finished."
        }
    }
}
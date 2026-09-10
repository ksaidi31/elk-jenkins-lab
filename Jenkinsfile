pipeline {

    agent any

    environment {
        APP_IMAGE = "elk-jenkins-lab-app:${BUILD_NUMBER}"
        COMPOSE_PROJECT_NAME = "elk-jenkins-lab"
    }

    stages {

        stage('Python Tests') {
            steps {
                echo 'Running Python tests...'

                sh '''
                    cd app
                    pytest -v
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

                    echo "Waiting for Logstash TCP port 5000..."

                    READY=false

                    for i in $(seq 1 30); do

                        if docker run --rm \
                            --network ${COMPOSE_PROJECT_NAME}_default \
                            busybox \
                            sh -c "nc -z logstash 5000" \
                            >/dev/null 2>&1
                        then
                            echo "Logstash is ready on port 5000."
                            READY=true
                            break
                        fi

                        echo "Logstash not ready yet... attempt $i/30"
                        sleep 2

                    done

                    if [ "$READY" != "true" ]; then
                        echo "ERROR: Logstash did not become ready."
                        docker logs logstash
                        exit 1
                    fi
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
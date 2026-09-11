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
                    pip install --no-cache-dir -r requirements.txt
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
                    echo "Building and starting ELK..."

                    docker compose up -d --build elasticsearch logstash kibana

                    echo "Waiting for Logstash API..."

                    READY=false

                    for i in $(seq 1 30); do

                        if docker exec logstash \
                            curl -fs http://localhost:9600/_node/pipelines \
                            >/dev/null 2>&1
                        then
                            echo "Logstash API is ready."
                            READY=true
                            break
                        fi

                        echo "Logstash not ready yet... attempt $i/30"
                        sleep 2

                    done

                    if [ "$READY" != "true" ]; then
                        echo "ERROR: Logstash did not become ready."
                        echo "===== Logstash logs ====="
                        docker logs logstash
                        exit 1
                    fi

                    echo "ELK stack is ready."
                '''
            }
        }

        stage('Initialize Kafka') {
            steps {
                echo 'Initializing Kafka...'

                sh '''
                    echo "Waiting for Kafka..."

                    READY=false

                    for i in $(seq 1 30); do

                        if docker exec kafka \
                            /opt/kafka/bin/kafka-topics.sh \
                            --bootstrap-server localhost:9092 \
                            --list \
                            >/dev/null 2>&1
                        then
                            echo "Kafka is ready."
                            READY=true
                            break
                        fi

                        echo "Kafka not ready yet... attempt $i/30"
                        sleep 2
                    done

                    if [ "$READY" != "true" ]; then
                        echo "ERROR: Kafka did not become ready."
                        docker logs kafka
                        exit 1
                    fi

                    echo "Creating Kafka topic..."

                    docker exec kafka \
                        /opt/kafka/bin/kafka-topics.sh \
                        --bootstrap-server localhost:9092 \
                        --create \
                        --if-not-exists \
                        --topic elk-jenkins-lab-logs \
                        --partitions 3 \
                        --replication-factor 1

                    echo "Kafka topic elk-jenkins-lab-logs is ready."
                '''
            }
        }

        stage('Verify Kafka topic') {
            steps {
                echo 'Verifying Kafka topic...'

                sh '''
                    docker exec kafka \
                    /opt/kafka/bin/kafka-topics.sh \
                    --bootstrap-server localhost:9092 \
                    --describe \
                    --topic elk-jenkins-lab-logs
                '''
            }
        }

        stage('Generate Logs') {
            steps {
                echo "Generating logs for Jenkins build ${BUILD_NUMBER}..."

                sh """
                    docker run --rm \
                    --network ${COMPOSE_PROJECT_NAME}_default \
                    -e BUILD_NUMBER=${BUILD_NUMBER} \
                    ${APP_IMAGE}
                """
            }
        }

        stage('Verify Kafka data') {
            steps {
                echo 'Verifying Kafka data...'

                sh '''
                    ./scripts/verify-kafka.sh
                '''
            }
        }

        stage('Elasticsearch healthcheck') {
            steps {
                echo 'Waiting for Elasticsearch...'

                sh '''
                    sleep 10

                    curl -f \
                      http://elasticsearch:9200/_cluster/health
                '''
            }
        }

        stage('Verify Elasticsearch data created') {
            steps {
                echo 'Verifying Elasticsearch data...'

                sh '''
                    ./scripts/verify-elasticsearch.sh
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
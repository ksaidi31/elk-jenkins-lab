#!/bin/sh

TOPIC="elk-jenkins-lab-logs"

echo "================================="
echo "Verifying Kafka data..."
echo "================================="

echo "Jenkins build: ${BUILD_NUMBER}"
echo "Kafka topic: ${TOPIC}"

echo "Checking Kafka..."

docker exec kafka \
    /opt/kafka/bin/kafka-topics.sh \
    --bootstrap-server localhost:9092 \
    --describe \
    --topic "${TOPIC}" \
    > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "ERROR: Kafka topic ${TOPIC} is not reachable."
    exit 1
fi

echo "Kafka topic is reachable."

echo "Reading Kafka messages..."

COUNT=$(docker exec kafka \
    /opt/kafka/bin/kafka-console-consumer.sh \
    --bootstrap-server localhost:9092 \
    --topic "${TOPIC}" \
    --from-beginning \
    --timeout-ms 5000 \
    2>/dev/null \
    | python3 -c '
import json
import sys

build_number = sys.argv[1]
count = 0

for line in sys.stdin:
    try:
        event = json.loads(line)

        if str(event.get("build_number")) == build_number:
            count += 1

    except json.JSONDecodeError:
        pass

print(count)
' "${BUILD_NUMBER}")

echo "Messages found for build ${BUILD_NUMBER}: ${COUNT}"

if [ "${COUNT}" -ne 10 ]; then
    echo "ERROR: Expected exactly 10 Kafka messages for build ${BUILD_NUMBER}."
    exit 1
fi

echo "SUCCESS: 10 Kafka messages found for build ${BUILD_NUMBER}."
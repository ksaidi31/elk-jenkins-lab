#!/bin/sh

INDEX="demo-app-elk-jenkins-*"

echo "================================="
echo "Verifying Elasticsearch data..."
echo "================================="

echo "Checking Elasticsearch..."

curl -fs http://elasticsearch:9200/_cluster/health > /dev/null

if [ $? -ne 0 ]; then
    echo "ERROR: Elasticsearch is not reachable."
    exit 1
fi

echo "Elasticsearch is reachable."

echo "Checking application logs..."

COUNT=$(curl -fs "http://elasticsearch:9200/${INDEX}/_count" \
    | python3 -c 'import json, sys; print(json.load(sys.stdin)["count"])')

echo "Documents found: ${COUNT}"

if [ "${COUNT}" -lt 10 ]; then
    echo "ERROR: Expected at least 10 documents."
    exit 1
fi

echo "SUCCESS: Application logs are present in Elasticsearch."
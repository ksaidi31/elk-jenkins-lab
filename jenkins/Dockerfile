FROM jenkins/jenkins:lts-jdk21

USER root

RUN apt-get update \
    && apt-get install -y \
        docker.io \
        # docker-compose-v2 \
        git \
        curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER jenkins
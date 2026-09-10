FROM jenkins/jenkins:lts-jdk21

USER root

RUN apt-get update \
    && apt-get install -y \
        docker.io \
        git \
        curl \
        python3 \
        python3-pip \
        python3-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/pytest-venv \
    && /opt/pytest-venv/bin/pip install --no-cache-dir pytest

ENV PATH="/opt/pytest-venv/bin:$PATH"

USER jenkins
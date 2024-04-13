#!/usr/bin/env bash

set -e
set -o pipefail
set -C

APP=$(basename $PWD | sed -e 's/^docker\-//')
TAG="$USER/$APP"
ACME_DOMAIN_FILE=./acme_domains.txt

DOCKER_OPTS="--name $APP"
if [[ -f .env ]]; then
    DOCKER_OPTS="$DOCKER_OPTS --env-file .env"
fi
if [[ -f $ACME_DOMAIN_FILE ]]; then
    DOCKER_OPTS="$DOCKER_OPTS -v $ACME_DOMAIN_FILE:/app/$ACME_DOMAIN_FILE"
fi
if [[ -n "$ACME_CHALLENGE_DIR" ]]; then
    DOCKER_OPTS="$DOCKER_OPTS -v $ACME_CHALLENGE_DIR:/vols/html"
fi
if [[ -n "$ACME_SSL_DIR" ]]; then
    DOCKER_OPTS="$DOCKER_OPTS -v $ACME_SSL_DIR:/vols/ssl"
fi
docker run $DOCKER_OPTS --rm -it $TAG:latest 

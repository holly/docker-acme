#!/usr/bin/env bash

set -e
set -o pipefail
set -C

APP=$(basename $PWD | sed -e 's/^docker\-//')
TAG="$USER/$APP"
ACME_DOMAIN_FILE=./acme_domains.txt

docker exec -it $APP /app/acme_remove.sh
docker kill $APP

#!/usr/bin/env bash

set -e
set -o pipefail

INSTALL_URL=https://get.acme.sh
ACME_HOME=/root/.acme.sh
ACME_SHELL=$ACME_HOME/acme.sh


term_handler() {
	if [[ $pid -ne 0 ]]; then
		kill -SIGTERM "$pid"
		wait "$pid"
	fi
	exit 143; # 128 + 15 -- SIGTERM
}
#trap 'kill ${!}; term_handler' SIGTERM SIGINT
trap 'term_handler' SIGTERM SIGINT

if [[ -z "$ACME_EMAIL" ]]; then
	echo "Error: ACME_EMAIL variable is not exists or undefined."
	exit 1
fi

if [[ -d $ACME_HOME ]]; then
	echo "Warn: acme.sh already installed."
else
	curl $INSTALL_URL | sh -s email=$ACME_EMAIL
fi


/app/acme_issue.sh

/usr/sbin/cron -f &
sleep INFINITY &
pid=$!
wait $pid
echo "exit."
exit

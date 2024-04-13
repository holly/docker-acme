#!/usr/bin/env bash

set -o pipefail

ACME_CHALLENGE_DIR=/vols/html
ACME_SSL_DIR=/vols/ssl
ACME_DOMAIN_LIST=/app/acme_domains.txt
ACME_HOME=/root/.acme.sh
ACME_SHELL=$ACME_HOME/acme.sh
ACME_ISSUE_OPTS="--issue -k ec-384"
ACME_DNSSLEEP_TIME=300
SEP="\t"

if [[ ! -f "$ACME_DOMAIN_LIST" ]]; then
	echo "Error: $ACME_DOMAIN_LIST not exists."
	exit 1
fi

if [[ ! -d $ACME_HOME ]]; then
	echo "Error: acme.sh already installed."
	exit 1
fi

issue_opts=$ACME_ISSUE_OPTS
cat $ACME_DOMAIN_LIST | while read line; do
	array=($(echo $line | perl -F"$SEP" -alne 'print join("\n", @F)'))
	num=${#array[@]}
	first=""
	for i in $(seq 0 $(($num-1))); do
		if [[ $i -eq 0 ]]; then
			ct=${array[$i]}
		else
			cn="${array[$i]}"
			issue_opts="$issue_opts -d $cn"
			if [[ $i -eq 1 ]]; then
				first=$cn
			fi
		fi
	done
	if [[ -n "$first" ]]; then
		check_domain=$($ACME_SHELL --list | grep -e "^$first" | awk '{ print $1 }')
		if [[ "$first" = "$check_domain" ]]; then
			echo "Warn: $first is already issued. skip."
			continue
		fi
	fi
	if [[ $ct = "http" ]]; then
		issue_opts="$issue_opts -w $ACME_CHALLENGE_DIR"
	else
		issue_opts="$issue_opts --dns $ct --dnssleep $ACME_DNSSLEEP_TIME"
	fi
	$ACME_SHELL $issue_opts
	$ACME_SHELL --install-cert -d $first --key-file "$ACME_SSL_DIR/${first}.key" --fullchain-file "$ACME_SSL_DIR/${first}.crt"  --ecc
done

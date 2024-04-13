#!/usr/bin/env bash

set -e
set -o pipefail

ACME_HOME=/root/.acme.sh
ACME_SHELL=$ACME_HOME/acme.sh
SEP="\t"

$ACME_SHELL --list | grep -v Main_Domain | awk '{ print $1 }' | while read domain; do
	$ACME_SHELL --revoke -d $domain --ecc
	$ACME_SHELL --remove -d $domain --ecc
	rm -frv "$ACME_HOME/${domain}_ecc"
done

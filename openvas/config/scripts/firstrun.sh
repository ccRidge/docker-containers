#!/bin/bash

mkdir -p /var/lib/openvas/private/CA /var/lib/openvas/CA /var/lib/openvas/scap-data/private

test -e /var/lib/openvas/CA/cacert.pem  || openvas-mkcert -q
openvas-nvt-sync
openvas-scapdata-sync
openvas-certdata-sync

test -e /var/lib/openvas/private/CA/cacert.pem || openvas-mkcert-client -n -i
service openvas-scanner stop
service openvas-manager stop
service openvas-gsa stop

openvassd
openvasmd --migrate
openvasmd --rebuild --progress
killall openvassd
sleep 15
service openvas-scanner start
service openvas-manager start
service openvas-gsa start


#!/bin/bash

mkdir -p /var/lib/openvas/private/CA /var/lib/openvas/CA /var/lib/openvas/scap-data/private

openvas-nvt-sync 
openvas-scapdata-sync
openvas-certdata-sync

service openvas-scanner restart
service openvas-manager restart
openvas-mkcert-client -n om -i
openvasmd --rebuild --progress

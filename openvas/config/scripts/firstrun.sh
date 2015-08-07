#!/bin/bash

openvas-nvt-sync 
openvas-scapdata-sync
openvas-certdata-sync

service openvas-scanner restart
service openvas-manager restart
openvas-mkcert-client -n om -i
openvasmd --rebuild --progress

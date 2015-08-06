#!/bin/bash

openvas-nvt-sync 
openvas-scapdata-sync
openvas-certdata-sync

service openvas-scanner restart
service openvas-manager restart
openvasmd --rebuild --progress

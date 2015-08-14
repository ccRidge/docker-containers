#!/bin/bash

mkdir -p /var/lib/openvas/private/CA /var/lib/openvas/CA /var/lib/openvas/scap-data/private
killall openvassd openvasmd gsad

test -e /var/lib/openvas/CA/cacert.pem  || sudo openvas-mkcert -q
sudo openvas-nvt-sync
sudo openvas-scapdata-sync
sudo openvas-certdata-sync

test -e /var/lib/openvas/private/CA/cacert.pem || sudo openvas-mkcert-client -n -i

sudo openvassd
# wait for openvassd to be listening for connections
for (( ; ; ))
do
     if ps -eaf | egrep -q "[o]penvassd: Waiting for incoming connections"
     then
         break
     else
         echo "[INFO] - `date` - Sleeping for 30 seconds.  Waiting for openvassd to be listening for incoming connections."
         sleep 30
     fi
done

sudo openvasmd --update
sudo openvasmd --migrate
sudo openvasmd --rebuild --progress
sudo openvasmd --create-user=admin
sudo openvasmd --user=admin --new-password=admin

sudo gsad

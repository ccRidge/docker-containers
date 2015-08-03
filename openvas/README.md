OpenVAS image for Docker
==============

A Docker container for OpenVAS 8 on the phusion/baseimage:0.9.15 image.  By default, the latest images includes the OpenVAS Base as well as the NVTs and Certs required to run OpenVAS.

Requirements
------------
Docker
Ports available: 443, 9390, 9391

Usage
-----

Simply run:

```
docker run -d -p 443:443 -p 9390:9390 -p 9391:9391 ccRidge/docker-containers/openvas
```

This will grab the container from the docker registry and start it up.  Openvas startup can take some time (4-5 minutes while NVT's are scanned and databases rebuilt), so be patient.  Once you see a `gasd` process in the top command below, the web ui is good to go.  Goto `https://<machinename>`

```
Username: admin
Password: openvas
```

To check the status of the process, run:

```
docker top ccRidge/docker-containers/openvas
```

In the output, look for the process scanning cert data.  It contains a percentage.

To run bash inside the container run:

```
docker exec -it <container id> bash
```

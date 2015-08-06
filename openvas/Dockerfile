# OpenVAS-8
# Based on: https://github.com/mikesplain/openvas-docker/blob/master/Dockerfile/

FROM phusion/baseimage:0.9.15
MAINTAINER ccridge <cl.mail.forwarding@gmail.com>
RUN add-apt-repository ppa:mrazavi/openvas -y && \
    apt-get update -y && \
    apt-get install \
        openvas \
        sqlite3

CMD /openvas/start.sh

# Expose UI
EXPOSE 443 9390 9391 9392

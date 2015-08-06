# OpenVAS-8
# Based on: https://github.com/mikesplain/openvas-docker/blob/master/Dockerfile/

FROM phusion/baseimage:0.9.15
MAINTAINER ccridge <cl.mail.forwarding@gmail.com>
RUN add-apt-repository ppa:mrazavi/openvas -y && \
    apt-get update -y && \
    apt-get install -y \
        openvas \
        sqlite3

# Expose UI
EXPOSE 443 9390 9391 9392

# Add firstrun.sh to execute during container startup
RUN mkdir -p /etc/my_init.d
ADD /config/scripts/firstrun.sh /etc/my_init.d/firstrun.sh
RUN chmod +x /etc/my_init.d/firstrun.sh

FROM phusion/baseimage:0.9.15

MAINTAINER ccridge <cl.mail.forwarding@gmail.com>
# Based on the work of needo <needo@superhero.org>, Eric Schultz <eric@startuperic.com> and Tim Haak <tim@haak.co.uk>

ENV DEBIAN_FRONTEND noninteractive

# Set correct environment variables
ENV HOME /root

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# chfn workaround - Known issue within Dockers
RUN ln -s -f /bin/true /usr/bin/chfn

# The Nessus directory. Where the binary, config, and database is
#RUN rm -rf /opt
VOLUME /data

# Install Nessus
RUN apt-get -q update
RUN apt-get install -qy gdebi-core wget

RUN wget -O /tmp/Nessus.deb "https://downloads.nessus.org/nessus3dl.php?file=Nessus-6.4.2-ubuntu1110_amd64.deb&licence_accept=yes&t=5ef69ed6e720e232c8bdfb50b2ec6524"
RUN chmod +x /tmp/Nessus.deb
RUN gdebi -n /tmp/Nessus.deb

EXPOSE 8834

# Add nessus to runit
RUN mkdir -p /etc/my_init.d
RUN echo '#!/bin/bash' > /etc/my_init.d/firstrun.sh
RUN echo 'exec service nessusd start' >> /etc/my_init.d/firstrun.sh
RUN chmod +x /etc/my_init.d/firstrun.sh

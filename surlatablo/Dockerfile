FROM phusion/baseimage:0.9.15

MAINTAINER ccridge <cl.mail.forwarding@gmail.com>
# Based on the work of Eric Schultz <eric@startuperic.com> and needo <needo@superhero.org>

ENV DEBIAN_FRONTEND noninteractive

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Install python and encoder tools
RUN add-apt-repository "deb http://ppa.launchpad.net/jon-severinsson/ffmpeg/ubuntu trusty main"
RUN apt-get update && apt-get install -y --force-yes ffmpeg python-pyudev wget
RUN apt-get clean

# Bring in our config and data files path
VOLUME ["/data"]
VOLUME ["/config"]
VOLUME ["/transcode"]

RUN mkdir -p /root/surlatablo/conf /root/surlatablo/scripts

ADD /config/cron.daily/daily_cpFromTablo /etc/cron.daily/daily_cpFromTablo
ADD /config/conf/example_surlatablo.conf /root/surlatablo/conf/example_surlatablo.conf
ADD /config/scripts/example_cpFromTablo /root/surlatablo/scripts/example_cpFromTablo

RUN chmod +x /etc/cron.daily/daily_cpFromTablo /root/surlatablo/scripts/example_cpFromTablo

# Add firstrun.sh to execute during container startup
RUN mkdir -p /etc/my_init.d
ADD /config/scripts/firstrun.sh /etc/my_init.d/firstrun.sh
RUN chmod +x /etc/my_init.d/firstrun.sh

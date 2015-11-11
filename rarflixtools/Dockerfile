FROM phusion/baseimage:rel-0.9.15

MAINTAINER ccridge <cl.mail.forwarding@gmail.com>
#Based on the work of Eric Schultz <eric@startuperic.com> and needo <needo@superhero.org>

ENV DEBIAN_FRONTEND noninteractive

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Install PHP5
RUN apt-get update && apt-get install -y php5 php5-gd php5-curl php5-json git-core
RUN apt-get clean

# Pull down latest Rar Flix Tools from Github
RUN mkdir -p /var/www/html
RUN git clone https://github.com/ljunkie/RARflixTools /var/www/html/RARflixTools

# Internally uses port 32499, remap using docker
EXPOSE 32499/tcp

# Bring in our config files
VOLUME ["/config"]

# Add firstrun.sh to execute during container startup
RUN mkdir -p /etc/my_init.d
ADD firstrun.sh /etc/my_init.d/firstrun.sh
RUN chmod +x /etc/my_init.d/firstrun.sh

# Also add RAR Flix Tools 
ADD rarflixtools.sh /etc/my_init.d/rarflixtools.sh
RUN chmod +x /etc/my_init.d/rarflixtools.sh

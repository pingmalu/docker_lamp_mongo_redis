FROM ubuntu:latest
MAINTAINER MaLu <malu@malu.me> 

ADD sources.list /etc/apt/sources.list

# Install packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server pwgen
RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
RUN apt-get install -y build-essential g++ curl libssl-dev git vim libxml2-dev python-software-properties software-properties-common byobu htop man unzip lrzsz wget supervisor apache2 libapache2-mod-php5 redis-server php5-redis pwgen php-apc php5-mcrypt && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN apt-get install -y python-pip python-pyside xvfb
RUN apt-get install -y mongodb php5-dev

# Add files.
ADD home/.bashrc /home/.bashrc
ADD home/.gitconfig /home/.gitconfig
ADD home/.scripts /home/.scripts

ADD start-apache2.sh /start-apache2.sh
ADD start-redis.sh /start-redis.sh
ADD start-mongodb.sh /start-mongodb.sh
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-redis.conf /etc/supervisor/conf.d/supervisord-redis.conf
ADD supervisord-sshd.conf /etc/supervisor/conf.d/supervisord-sshd.conf
ADD supervisord-mongodb.conf /etc/supervisor/conf.d/supervisord-mongodb.conf

ADD set_root_pw.sh /set_root_pw.sh
ADD run.sh /run.sh
#RUN chmod +x /*.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

RUN mkdir -p /app/www && rm -fr /var/www/html && ln -s /app/www /var/www/html
RUN mkdir -p /app/data
RUN mkdir -p /app/mongodb/db

RUN mkdir /root/.pip
ADD pip.conf /root/.pip/pip.conf
#ADD msyh.ttf /usr/share/fonts/msyh.ttf
#RUN fc-cache

ENV HOME /root
ENV REDIS_DIR /app/data
WORKDIR /root

VOLUME ["/root","/app"]

#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 100M
ENV PHP_POST_MAX_SIZE 100M

ENV AUTHORIZED_KEYS **None**

EXPOSE 22 80 6379 443 21 23 8080 8888 8000 27017
CMD ["/run.sh"]

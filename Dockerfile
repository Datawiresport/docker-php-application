FROM ubuntu:14.04
MAINTAINER Boyan Bonev <b.bonev@redbuffstudio.com>

#Setup container environment parameters
ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No

#Configure locale.
RUN locale-gen en_US en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

#Prepare the image
RUN apt-get -y update

#Make our life easy.
RUN apt-get install -y -q python-software-properties software-properties-common bash-completion

#Install NGINX
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get -y update
RUN apt-get install -y nginx=1.6.2-4+trusty0

#Install PHP 5.6.2
RUN echo "deb http://ppa.launchpad.net/ondrej/php5-5.6/ubuntu trusty main" >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key E5267A6C
RUN apt-get -y update
RUN apt-get install -y -q php5-cli php5-fpm php5-mysql php5-curl php5-pgsql php5-mongo php5-gd php5-intl php5-imagick php5-mcrypt php5-memcache php5-xmlrpc php5-xsl

# Edit PHP config
RUN sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ UTC/g' /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i -e "s/;listen.mode\s*=\s*0660/listen.mode = 0666/g" /etc/php5/fpm/pool.d/www.conf

#Install supervisor
RUN apt-get install -y supervisor=3.0b2-1

ADD ./supervisor/conf.d /etc/supervisor/conf.d
ADD ./supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD ./nginx/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n"]
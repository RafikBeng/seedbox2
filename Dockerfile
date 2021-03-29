# HADOPIBOX

FROM ubuntu:groovy
LABEL maintainer="badrorafik@gmail.com"

# env
ENV TERM xterm
ENV DEBIAN_FRONTEND noninteractive
ENV RTORRENT_DEFAULT /opt/rtorrent

ENV RTORRENT_VERSION 0.9.8
ENV RUTORRENT_VERSION 3.10
ENV H5AI_VERSION 0.30.0
ENV CAKEBOX_VERSION v1.8.6

# install tools ===============================================================

RUN apt -qq --force-yes -y update 
RUN apt install -y vim curl nano \
        supervisor nginx php-cli php-fpm php-gd \
        zip unzip unrar-free \
        mediainfo imagemagick ffmpeg \
        rtorrent nodejs npm python3-pip sox git \
        --no-install-recommends && rm -r /var/lib/apt/lists/* \
        && apt-get --purge autoremove -y




RUN mkdir -p /var/www \
        && curl -sSL https://github.com/Novik/ruTorrent/archive/refs/tags/v${RUTORRENT_VERSION}.tar.gz | tar xz -C /var/www \
        && mv /var/www/ruTorrent-${RUTORRENT_VERSION} /var/www/rutorrent


RUN curl -sSL http://getcomposer.org/installer | php \
        && mv /composer.phar /usr/bin/composer \
        && chmod +x /usr/bin/composer

RUN npm install -g bower

RUN pip install cloudscraper 

RUN git clone https://github.com/cakebox/cakebox-light.git /var/www/cakebox \
    && cd /var/www/cakebox \
    && git checkout tags/$(git describe --abbrev=0) \
    && composer install \
    && bower install --config.interactive=false --allow-root \
    && cp config/default.php.dist config/default.php \
    && sed -i "/cakebox.root/s,/var/www,${RTORRENT_DEFAULT}/share," config/default.php

# install h5ai ================================================================

RUN curl -sSL https://release.larsjung.de/h5ai/h5ai-$H5AI_VERSION.zip -o /tmp/h5ai.zip \
        && unzip /tmp/h5ai.zip -d /var/www/ \
        && rm -f /tmp/h5ai.zip \
        && ln -s ${RTORRENT_DEFAULT}/share /var/www/downloads



ADD src /
COPY .htpasswd /opt/rtorrent/.htpasswd
# nginx
RUN ln -s /etc/nginx/sites-available/rutorrent.conf /etc/nginx/sites-enabled \
        && rm /etc/nginx/sites-enabled/default

# rtorrent
RUN mkdir -p ${RTORRENT_DEFAULT}/share \
        && mkdir -p ${RTORRENT_DEFAULT}/session \
        && mkdir -p ${RTORRENT_DEFAULT}/log \
        && mkdir -p ${RTORRENT_DEFAULT}/watch \
        && chown -R www-data:www-data /var/www


EXPOSE 80
EXPOSE 65432
EXPOSE 65432/udp
EXPOSE 6981/udp
RUN chmod 777 /go.sh  
CMD ["/go.sh"]

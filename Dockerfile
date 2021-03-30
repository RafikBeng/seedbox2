FROM badrorafik/qbittorrent:1.0

RUN apt-get -y update
RUN apt-get install -y php-cli php-fpm php-gd nginx \
                       curl git nodejs npm \
                       --no-install-recommends && rm -r /var/lib/apt/lists/* \
                       && apt-get --purge autoremove -y



RUN curl -sSL http://getcomposer.org/installer | php \
        && mv /composer.phar /usr/bin/composer \
        && chmod +x /usr/bin/composer

RUN npm install -g bower

RUN mkdir -p /var/www

RUN git clone https://github.com/cakebox/cakebox.git /var/www/cakebox \
    && cd /var/www/cakebox \
    && git checkout tags/$(git describe --abbrev=0) \
    && composer install \
    && bower install --config.interactive=false --allow-root \
    && cp config/default.php.dist config/default.php \
    && sed -i "/cakebox.root/s,/var/www,/downloads," config/default.php

COPY .htpasswd /.htpasswd
COPY root/ /
COPY default /etc/nginx/sites-available/default
EXPOSE 80 6881 6881/udp 8080
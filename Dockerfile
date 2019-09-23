FROM ubuntu:18.04
MAINTAINER forever88959@gmail.com

ENV DEBIAN_FRONTEND=noninteractive \
    TERM="xterm-color" \
    TZ="Asia/Shanghai" \
    LANGUAGE="en_US:en" \
    LANG="en_US.UTF-8" \
    COMPOSER_PROCESS_TIMEOUT=40000 \
    COMPOSER_HOME="/usr/local/share/composer"
    
# Install cURL
RUN apt-get -q update && apt-get install -yq curl bash vim git unzip supervisor && apt-get -y autoclean && apt-get -y clean

# Install PHP
RUN apt-get install -yq php7.2-fpm php7.2-cli && \
    apt-get -y autoclean && apt-get -y clean && \
    mkdir -p /run/php && \
    mkdir -p /var/lib/workspace && \
    mkdir -p /var/log/php7 && \
    touch /var/log/php7/cgi.log && \
    touch /var/log/php7/cli.log && \
    chown -R www-data:www-data /var/log/php7 && \
    sed -i 's/^listen\s*=.*$/listen = 0.0.0.0:9000/' /etc/php/7.2/fpm/pool.d/www.conf && \
    sed -i 's/^error_log\s*=.*$/error_log = syslog/' /etc/php/7.2/fpm/php-fpm.conf && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = \/var\/log\/php7\/cgi.log/' /etc/php/7.2/fpm/php.ini && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = \/var\/log\/php7\/cli.log/' /etc/php/7.2/cli/php.ini

RUN apt-get install -yq php7.2-intl php7.2-gd php7.2-mysql php-redis php7.2-sqlite php7.2-curl php7.2-zip php7.2-mbstring php7.2-ldap php-dev

RUN apt-get install -yq libyaml-dev && \
    pecl install yaml-2.0.4 && \
    echo "extension=yaml.so" > /etc/php/7.2/mods-available/yaml.ini && \
    phpenmod yaml

# Install Swoole
RUN pecl install swoole && \
    echo "extension=swoole.so" > /etc/php/7.2/mods-available/swoole.ini && \
    phpenmod swoole

# Install Composer
RUN mkdir -p /usr/local/bin && (curl -sL https://getcomposer.org/installer | php) && \
    mv composer.phar /usr/local/bin/composer && \
    echo 'export PATH="/usr/local/share/composer/vendor/bin:$PATH"' >> /etc/profile.d/composer.sh

ADD supervisor.php7-fpm.conf /etc/supervisor/conf.d/php7-fpm.conf

EXPOSE 9000

WORKDIR /var/lib/workspace

CMD ["/usr/bin/supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]

FROM debian:buster

LABEL maintainer "opsxcq@strm.sh"

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    debconf-utils \
    gnupg && \
    echo mariadb-server mysql-server/root_password password vulnerables | debconf-set-selections && \
    echo mariadb-server mysql-server/root_password_again password vulnerables | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apache2 \
    mariadb-server \
    php \
    php-mysql \
    php-pgsql \
    php-pear \
    php-gd \
    curl \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY dvwa /var/www/html

COPY config.inc.php /var/www/html/config/

RUN chown www-data:www-data -R /var/www/html && \
    rm /var/www/html/index.html

RUN service mysql start && \
    sleep 3 && \
    mysql -uroot -pvulnerables -e "CREATE USER app@localhost IDENTIFIED BY 'vulnerables';CREATE DATABASE dvwa;GRANT ALL privileges ON dvwa.* TO 'app'@localhost;"

RUN curl -s https://download.sqreen.com/php/install.sh > sqreen-install.sh && bash sqreen-install.sh 'org_123456789012345678901234567890123456789012345678901234567890' '${SQREEN_APP_NAME}'
RUN sqreen-installer config '${SQREEN_TOKEN}' '${SQREEN_APP_NAME}'
RUN sed -i s/\\\\//g /etc/php/7.3/apache2/conf.d/50-sqreen.ini

RUN sed -i s/"allow_url_include = Off"/"allow_url_include = On"/ /etc/php/7.3/apache2/php.ini

EXPOSE 80

COPY main.sh /
ENTRYPOINT ["/main.sh"]

FROM php:7.3-apache-stretch
EXPOSE 80
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends zlib1g-dev libicu-dev g++ \
    libldap2-dev libmagickwand-dev git-core locales libssl-dev gettext \
    libpq-dev mysql-client postgresql-client && apt-get clean autoclean && \
    apt-get autoremove -y && rm -rf /var/lib/{apt,dpkg,cache,log}/
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen
RUN docker-php-ext-install pdo_pgsql
RUN docker-php-ext-install gettext
RUN docker-php-ext-install intl
RUN docker-php-ext-install ldap
RUN docker-php-ext-install json
RUN docker-php-ext-install pdo_mysql
RUN pecl install imagick htmlpurifier
RUN a2enmod rewrite
RUN git clone https://github.com/Icinga/icingaweb2.git /usr/share/icingaweb2
RUN git clone https://github.com/Icinga/icingaweb2-module-director.git \
    /usr/share/icingaweb2/modules/director
RUN addgroup --system icingaweb2 && usermod -a -G icingaweb2 www-data
RUN /usr/share/icingaweb2/bin/icingacli setup config webserver apache \
    --document-root /usr/share/icingaweb2/public
RUN /usr/share/icingaweb2/bin/icingacli setup config directory
RUN /usr/share/icingaweb2/bin/icingacli module enable director
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "apache2-foreground" ]

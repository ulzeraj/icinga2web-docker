FROM php:7.3-apache-stretch
RUN apt update && apt-get install -y curl apt-transport-https gnupg
RUN curl https://packages.icinga.com/icinga.key | apt-key add -
RUN printf "deb http://packages.icinga.com/debian icinga-stretch main\n" > \
    /etc/apt/sources.list.d/icinga2.list
RUN printf "deb-src http://packages.icinga.com/debian icinga-stretch main\n" >> \
    /etc/apt/sources.list.d/icinga2.list
RUN apt update && apt upgrade -y
RUN apt install -y locales icingacli icingaweb2 git-core 
RUN apt-get clean autoclean && apt-get autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/
RUN sed -i 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen
RUN locale-gen
RUN curl -O /v1.6.2.tar.gz https://github.com/Icinga/icingaweb2-module-director/archive/v1.6.2.tar.gz
RUN mkdir /usr/share/icingaweb2/modules/director
RUN tar xf /v1.6.2.tar.gz -C /usr/share/icingaweb2/modules/director && rm /v1.6.2.tar.gz
RUN cp /usr/share/icingaweb2/packages/files/apache/icingaweb2.conf /etc/apache2/conf-enabled/ && \
    echo "RedirectMatch ^/$ /icingaweb2" >> /etc/apache2/conf-enabled/redirect.conf && \
    a2enmod rewrite && echo "date.timezone = America\Sao_Paulo" > /usr/local/etc/php/conf.d/timeszone.ini
RUN icingacli module enable monitoring
RUN icingacli module enable graphite
RUN icingacli module enable director
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "apache2-foreground" ]

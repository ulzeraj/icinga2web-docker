FROM php:7.0-fpm
RUN apt-get install -y curl apt-transport-https gnupg
RUN curl https://packages.icinga.com/icinga.key | apt-key add -
RUN printf "deb http://packages.icinga.com/ubuntu icinga-bionic main\n" > \
    /etc/apt/sources.list.d/icinga2.list
RUN printf "deb-src http://packages.icinga.com/ubuntu icinga-bionic main\n" >> \
    /etc/apt/sources.list.d/icinga2.list
RUN apt update && apt upgrade -y
RUN apt install -y locales icingacli icingaweb2 icingaweb2-common php-icinga \
    icingaweb2-module-monitoring icingaweb2-module-doc git-core 
RUN apt-get clean autoclean && apt-get autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/
RUN sed -i 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen
RUN locale-gen

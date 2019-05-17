#!/bin/bash
export PATH=${PATH}:/usr/share/icingaweb2/bin

set -ex

mkdir -p /etc/icingaweb2/modules

if [ ! -f /etc/icingaweb2/resources.ini ]; then
    if [ "$DATABASE_ENGINE" == "mysql" ]; then 
    printf "
[icingaweb2]
type                = \"db\"
db                  = \"mysql\"
host                = \"${MYSQL_HOST}\"
port                = \"${MYSQL_PORT}\"
dbname              = \"${MYSQL_DATABASE}\"
username            = \"${MYSQL_USERNAME}\"
password            = \"${MYSQL_PASSWORD}\"
[icinga2]
type                = \"db\"
db                  = \"mysql\"
host                = \"${MYSQL_HOST}\"
port                = \"${MYSQL_PORT}\"
dbname              = \"${MYSQL_DATABASE}\"
username            = \"${MYSQL_USERNAME}\"
password            = \"${MYSQL_PASSWORD}\"\n" > /etc/icingaweb2/resources.ini
    fi 
    if [ "$DATABASE_ENGINE" == "pgsql" ]; then 
    printf "
[icingaweb2]
type                = \"db\"
db                  = \"pgsql\"
host                = \"${PGSQL_HOST}\"
port                = \"${PGSQL_PORT}\"
dbname              = \"${PGSQL_DATABASE}\"
username            = \"${PGSQL_USERNAME}\"
password            = \"${PGSQL_PASSWORD}\"
[icinga2]
type                = \"db\"
db                  = \"pgsql\"
host                = \"${PGSQL_HOST}\"
port                = \"${PGSQL_PORT}\"
dbname              = \"${PGSQL_DATABASE}\"
username            = \"${PGSQL_USERNAME}\"
password            = \"${PGSQL_PASSWORD}\"\n" > /etc/icingaweb2/resources.ini
    fi
fi


if [ ! -f /etc/icingaweb2/config.ini ]; then
    printf "[logging]
log                 = \"syslog\"
level               = \"ERROR\"
application         = \"icingaweb2\"
[preferences]
type                = \"db\"
resource            = \"icingaweb2\"\n" > /etc/icingaweb2/config.ini
fi


if [ ! -f /etc/icingaweb2/authentication.ini ]; then
    printf "
[icingaweb2]
backend             = \"db\"
resource            = \"icingaweb2\"\n" > /etc/icingaweb2/authentication.ini
fi

if [ ! -f /etc/icingaweb2/roles.ini ]; then
    printf "
[admins]
users               = \"icingaadmin\"
permissions         = \"*\"\n" > /etc/icingaweb2/authentication.ini
fi 


if [ ! -f /etc/icingaweb2/modules/monitoring/config.ini ]; then
    printf "
[security]
protected_customvars = \"*pw*,*pass*,community\"\n" > /etc/icingaweb2/modules/monitoring/config.ini
fi


if [ ! -f /etc/icingaweb2/modules/monitoring/backends.ini ]; then
    printf "
[icinga2]
type                = \"ido\"
resource            = \"icinga2\"\n" > /etc/icingaweb2/modules/monitoring/backends.ini
fi


if [ ! -f /etc/icingaweb2/modules/monitoring/commandtransports.ini ]; then
    printf "
[icinga2]
transport = \"api\"
host = \"${ICINGA_API_HOST}\"
port = \"${ICINGA_API_PORT}\"
username = \"${ICINGA_API_USERNAME}\"
password = \"${ICINGA_API_PASSWORD}\"\n" > /etc/icingaweb2/modules/monitoring/commandtransports.ini
fi


config=/etc/icingaweb2
if [ ! -e "${config}"/config.ini ]; then
    echo "Setting setup token from ICINGAWEB_SETUP_TOKEN"
    echo "${ICINGAWEB_SETUP_TOKEN}" > "$config"/setup.token
fi

echo "fixing permissions in $config"
chgrp -R www-data "$config"
find "$config" -type d -exec chmod g+ws {} \;
find "$config" -type f -exec chmod g+w {} \;

exec "$@"

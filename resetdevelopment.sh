#!/usr/bin/env bash

set -eo pipefail

echo ""
echo ""
echo ""
echo ""
echo "dont use for PRODUCTION!"
echo ""
echo ""
echo ""
echo ""
echo ""
sleep 2;


# defines
INSTALL_DIR=$PROJECT_PATH
MAGENTO_HOSTNAME=$PROJECT_HOST

DB_HOST=mysqlhost
DB_USER=$MYSQL_USER
DB_PASS=$MYSQL_ROOT_PASSWORD
DB_PORT=3306
DB_NAME=$MYSQL_DATABASE

APPLY_UPDATES=https://gist.githubusercontent.com/Rud5G/5b39ecef0560b0027627/raw/aa6c82d1f36c01933e86179a80ba35a2d00c7eba/apply-updates.php

# prevent unwanted deleting
echo ""
echo ""
echo ""
echo ""
echo "resetting entire magento installation in 10sec!, if git status has unexpected results use [ctrl]+C now!"
echo ""
echo ""
echo ""
echo ""
echo ""
sleep 10;


touch ${INSTALL_DIR}/htdocs/maintenance.flag
rm -rf ${INSTALL_DIR}/vendor
rm -rf ${INSTALL_DIR}/composer.lock


# start composer setup+install
cd ${INSTALL_DIR}
php /usr/bin/composer install -v

# php /usr/bin/composer run-script post-install-cmd -vvv -- --redeploy

wget -q ${APPLY_UPDATES} -O ${INSTALL_DIR}/htdocs/shell/apply-updates.php


echo "DROP DATABASE IF EXISTS ${DB_NAME}; CREATE DATABASE ${DB_NAME};" | mysql -h${DB_HOST} -p${DB_PASS} -P${DB_PORT} -u${DB_USER}

rm -f ${INSTALL_DIR}/htdocs/app/etc/local.xml && php -f ${INSTALL_DIR}/htdocs/install.php -- \
        --license_agreement_accepted "yes" \
        --locale "en_US" \
        --timezone "Europe/Berlin" \
        --default_currency "EUR" \
        --use_rewrites "yes" \
        --use_secure "no" \
        --use_secure_admin "no" \
        --skip_url_validation \
        --admin_firstname "FirstName" \
        --admin_lastname "LastName" \
        --admin_email "f.lastname@example.com" \
        --admin_username "admin" \
        --admin_password "magento123" \
        --url "http://${MAGENTO_HOSTNAME}/" \
        --secure_base_url "http://${MAG_HOST}/" \
        --db_host "${DB_HOST}" \
        --db_name "${DB_NAME}" \
        --db_user "${DB_USER}" \
        --db_pass "${DB_PASS}"
php ${INSTALL_DIR}/htdocs/shell/apply-updates.php run
rm -rf ${INSTALL_DIR}/htdocs/var/*
rm ${INSTALL_DIR}/htdocs/maintenance.flag

echo "installed"


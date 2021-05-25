#!/bin/bash

if [ -z $SQREEN_TOKEN ] || [ -z $SQREEN_APP_NAME ]; then
	echo "Starting DVWA without a token, Sqreen will be disabled!"
	echo "To start with Sqreen, run the following command:"
	echo "docker run --rm -e SQREEN_TOKEN=org_yourSqreenToken -e SQREEN_APP_NAME=DVWA -p 80:80 dvwa"
	sqreen-installer uninstall
else
	echo "Starting DVWA with Sqreen token $SQREEN_TOKEN and app name $SQREEN_APP_NAME"
	sqreen-installer config "${SQREEN_TOKEN}" "${SQREEN_APP_NAME}"
fi

if [ -n "$SQREEN_URL" ]; then
	sqreen-installer set_ini sqreen_url $SQREEN_URL
fi

chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

echo '[+] Starting mysql...'
service mysql start

echo '[+] Starting apache'
service apache2 start

while true
do
    tail -f /var/log/apache2/*.log
    exit 0
done

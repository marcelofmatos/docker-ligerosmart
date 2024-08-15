#!/bin/bash

# exit on error
set -o errexit

if [ -n "$MYSQL_HOST" ]; then
    ping -c 1 $MYSQL_HOST > /dev/null
    mysql -BN -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD -e '/* ping */  SELECT 1' $MYSQL_DATABASE > /dev/null
else
    ping -c 1 $POSTGRES_DB > /dev/null
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -c 'SELECT 1' > /dev/null
fi

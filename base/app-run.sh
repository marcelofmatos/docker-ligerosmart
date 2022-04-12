#!/usr/bin/env bash

if [ -f "$APP_DIR/.env" ]; then
    source "$APP_DIR/.env"
fi;

# stop script on SIGINT 
trap 'exit 130' INT

export INITSCREEN_DIR=/var/www/html
export PROGRESSBAR_FILE=$INITSCREEN_DIR/progress.txt
export START_WEBSERVER=${START_WEBSERVER:-1}
export START_SCHEDULER=${START_SCHEDULER:-1}
export START_SSHD=${START_SSHD:-0}
export DEBUG_MODE=${DEBUG_MODE:-0}
export RESTORE_DIR=${RESTORE_DIR:-"/app-backups/restore"}

# legacy variables
[ "$START_FRONTEND" == "1" ] && export START_WEBSERVER=1
[ "$START_BACKEND"  == "1" ] && export START_SCHEDULER=1

# set permissions on base dir
chown otrs:www-data $APP_DIR /app-backups
chmod 755 $APP_DIR /app-backups

echo "5" > $PROGRESSBAR_FILE


# init-screen
perl $INITSCREEN_DIR/httpserver.pl > /dev/null 2>&1 &
INITSCREEN_PID=$!

# set APP ENV vars
printenv | grep APP_ | sed 's/^\(.*\)$/export \1/g' > /etc/profile.d/app-env.sh

# check command before loop
command -v otrs.Console.pl > /dev/null && CONSOLE_COMMAND_FOUND=1
if [ -z $CONSOLE_COMMAND_FOUND ]; then
    echo "otrs.Console.pl not found"
    exit 1
fi;

if [ $START_SSHD != '0' ]; then
    if [ -z "$SSH_PASSWORD" ]; then
        echo "$0 - Set SSH_PASSWORD for otrs user or put your public RSA key on $APP_DIR/.ssh/authorized_keys"
    else
        # set otrs password
        echo -e "$SSH_PASSWORD\n$SSH_PASSWORD\n" | passwd otrs 2> /dev/null
    fi;
fi;

# database connection test
while [ "$DATABASE_CHECK" == 1 ] && ! su -c "otrs.Console.pl Maint::Database::Check" otrs 2> /tmp/console-maint-database-check.log; 
do
    egrep -o " Message: (.+)" /tmp/console-maint-database-check.log

    # init configuration if empty
    grep "database content is missing" /tmp/console-maint-database-check.log \
    && [ $START_WEBSERVER == '1' ] \
    && su -c "/app-init.sh" otrs \
    && otrs.SetPermissions.pl
    
    sleep 1;
done

if [ "$MIGRATIONS_CHECK" == 1 ] && [ -d "$APP_DIR/scripts/database/migrations" ] && [ "$START_WEBSERVER" == '1' ] && [ "$APP_NodeID" == '1' ]; then
    su -c "otrs.Console.pl Maint::Database::Migration::Apply" -s /bin/bash $APP_USER
fi

if [ "$START_SCHEDULER" == '1' ] && [ -f /var/spool/cron/crontabs/root ]; then
    # start crontab root
    crontab root /var/spool/cron/crontabs/root
fi;

# change old default branch name
git branch -m master main

echo "100" > $PROGRESSBAR_FILE

# stop init-screen
kill -9 $INITSCREEN_PID

# run services
exec supervisord -c /etc/supervisor/supervisord.conf

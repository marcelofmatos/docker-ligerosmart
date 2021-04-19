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
export DEBUG_MODE=${DEBUG_MODE:-1}
export RESTORE_DIR=${RESTORE_DIR:-"/app-backups/restore"}
export CODE_REPOSITORY="https://github.com/LigeroSmart/ligerosmart"
export CODE_BRANCH=${CODE_BRANCH:-"dev-6_0"}

echo "5" > $PROGRESSBAR_FILE


# init-screen
perl $INITSCREEN_DIR/httpserver.pl > /dev/null 2>&1 &
INITSCREEN_PID=$!

# set APP ENV vars
printenv | grep APP_ | sed 's/^\(.*\)$/export \1/g' > /etc/profile.d/app-env.sh

# code download

# do nothing if .git exists
if [ ! -d /opt/otrs/.git ]; then

    echo "15" > $PROGRESSBAR_FILE

    echo "$0 - downloading code from https://github.com/LigeroSmart/ligerosmart"

    set -x

    cd /opt/otrs
    git init
    # ignore modifications by otrs.SetPermissions.pl 
    git config core.fileMode false
    git remote add origin $CODE_REPOSITORY
    git fetch origin $CODE_BRANCH
    git checkout $CODE_BRANCH --force

    set +x
    
    mkdir -p /opt/otrs/var/article /opt/otrs/var/spool /opt/otrs/var/tmp
    chgrp www-data -R /opt/otrs
    chmod 775 -R /opt/otrs

fi;

# check command before loop
command -v otrs.Console.pl > /dev/null && CONSOLE_COMMAND_FOUND=1
if [ -z $CONSOLE_COMMAND_FOUND ]; then
    echo "otrs.Console.pl not found"
    exit 1
fi;

# database connection test
while ! su -c "otrs.Console.pl Maint::Database::Check" otrs 2> /tmp/console-maint-database-check.log; 
do
    egrep -o " Message: (.+)" /tmp/console-maint-database-check.log

    # init configuration if empty
    grep "database content is missing" /tmp/console-maint-database-check.log \
    && [ $START_WEBSERVER == '1' ] \
    && su -c "/app-init.sh" otrs
    
    sleep 1;
done

if [ $START_SSHD != '0' ]; then
    if [ -z "$SSH_PASSWORD" ]; then
        echo "$0 - Set SSH_PASSWORD for otrs user or put your public RSA key on /opt/otrs/.ssh/authorized_keys"
    else
        # set otrs password
        echo -e "$SSH_PASSWORD\n$SSH_PASSWORD\n" | passwd otrs 2> /dev/null
    fi;
fi;

echo "100" > $PROGRESSBAR_FILE

# stop init-screen
kill -9 $INITSCREEN_PID

# run services
exec supervisord -c /etc/supervisor/supervisord.conf

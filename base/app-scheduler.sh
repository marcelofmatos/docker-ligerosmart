#!/bin/bash
_term() {
    echo 'Terminating scheduler'
    su -c "otrs.Daemon.pl stop" otrs 
}

trap _term SIGINT SIGTERM

export START_SCHEDULER=${START_SCHEDULER:-1}
export DEBUG_MODE=${DEBUG_MODE:-0}
export APP_USER=${APP_USER:-otrs}
export SMTPSERVER=${SMTPSERVER:-mail}
export SMTPPORT=${SMTPPORT:-25}
export EMAIL=${EMAIL:-"otrs@localhost"}
export EMAILPASSWORD=${EMAILPASSWORD:-"passw0rd"}

su -c "otrs.Daemon.pl start" otrs 
Cron.sh start otrs 
/usr/sbin/cron -f -L 15 &
wait "$!"
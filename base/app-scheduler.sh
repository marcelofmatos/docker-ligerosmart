#!/bin/bash
_term() {
    echo 'Terminating scheduler'
    su -c "otrs.Daemon.pl stop" otrs 
}

trap _term SIGINT SIGTERM

su -c "otrs.Daemon.pl start" otrs 
Cron.sh start otrs 
/usr/sbin/cron -f -L 15 &
wait "$!"
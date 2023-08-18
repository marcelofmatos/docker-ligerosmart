#!/bin/bash
#set -x
HEARTBEAT_FILE=/tmp/healthcheck_on

if [ $(pgrep httpserver.pl) ]; then
  exit 0
fi

if [ -z $(pgrep starman) ]; then
  exit 0
fi

if [ ! -f "$HEARTBEAT_FILE" ]; then
  touch $HEARTBEAT_FILE
  exit 0
fi

if test -z `find "$HEARTBEAT_FILE" -mmin +1`; then # 1 minute
  # heartbeat ok
  exit 0
fi

# WEBSERVER test
if [ "$START_WEBSERVER" == "1" ]; then
    touch $HEARTBEAT_FILE
    curl -m 50 -f -s http://localhost/otrs/index.pl?healthcheck -o /dev/null || exit 1
fi;

# SCHEDULER test
#if [ "$START_SCHEDULER" == "1" ]; then 
#    # TODO
#fi;


# returns ok
exit 0
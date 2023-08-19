#!/bin/bash
#set -x
HEARTBEAT_FILE=/tmp/healthcheck_on

if [ "$(pgrep -f httpserver.pl)" ]; then
  exit 0
fi

if [ -z "$(pgrep -f apache)" ]; then
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
    curl -m 50 -f -s http://127.0.0.1/otrs/index.pl?healthcheck -o /dev/null || exit 1
    touch $HEARTBEAT_FILE
fi;

# SCHEDULER test
if [ "$START_SCHEDULER" == "1" ]; then 
  if [ -z "$(pgrep -f otrs.Daemon.pl)" ]; then
    exit 1
  fi
  touch $HEARTBEAT_FILE
fi;


# returns ok
exit 0
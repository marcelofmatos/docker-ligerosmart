#!/bin/bash
#set -x
HEARTBEAT_FILE=/tmp/healthcheck_on

if [ ! -f "$HEARTBEAT_FILE" ]; then
  touch $HEARTBEAT_FILE
  exit 0
fi

if test -z `find "$HEARTBEAT_FILE" -mmin +1`; then # 1 minute
  # heartbeat ok
  exit 0
fi

# SCHEDULER test
if [ "$START_SCHEDULER" == "1" ]; then 
  if [ -z "$(pgrep -f otrs.Daemon.pl)" ]; then
    exit 1
  fi
  touch $HEARTBEAT_FILE
fi;


# returns ok
exit 0
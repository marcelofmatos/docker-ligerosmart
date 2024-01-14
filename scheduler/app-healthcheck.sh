#!/bin/bash
#set -x
HEARTBEAT_FILE=/tmp/healthcheck_on
HEARTBEAT_INTERVAL=${HEARTBEAT_INTERVAL:-4} # minutes

if [ ! -f "$HEARTBEAT_FILE" ]; then
  touch $HEARTBEAT_FILE
  exit 0
fi

if test -z `find "$HEARTBEAT_FILE" -mmin +$HEARTBEAT_INTERVAL`; then
  # heartbeat ok
  exit 0
fi

# SCHEDULER test
if [ "$START_SCHEDULER" == "1" ]; then 
  if [ -z "$(pgrep -f otrs.Daemon.pl)" ]; then
    exit 1
  fi
fi;

# CRON config test
cron_folder=/opt/otrs/var/cron
cron_time_interval=$((HEARTBEAT_INTERVAL * 60))
modified_files=$(find "$cron_folder" -type f -mmin -$cron_time_interval)
if [ -n "$modified_files" ]; then
  touch $HEARTBEAT_FILE
  exit 1
fi

touch $HEARTBEAT_FILE


# returns ok
exit 0
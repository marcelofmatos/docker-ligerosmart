#!/bin/bash

# FRONTEND test
if [ "$START_FRONTEND" == "1" ] && [ -z $(pgrep httpserver.pl) ]; then 
    curl -wfs http://localhost/otrs/index.pl?healthcheck -o /dev/null || exit 1
fi;

# returns ok
exit 0
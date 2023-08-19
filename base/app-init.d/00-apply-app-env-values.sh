#!/bin/bash


ENV_LIST=$(printenv | cut -f 1 -d '=' | grep APP_ )

for ENV_NAME in $ENV_LIST; do
    otrs.Console.pl Admin::Config::Read --setting-name "$ENV_NAME" | sed -n '3,4p' 2> /dev/null
    if [ "$?" == "0" ]; then
        otrs.Console.pl Admin::Config::Update --setting-name "$ENV_NAME" --value="${!ENV_NAME}" --no-deploy
    fi
done

# apply
otrs.Console.pl Maint::Config::Rebuild
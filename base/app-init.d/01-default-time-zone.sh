#!/usr/bin/env bash

if [ -z "$APP_UserDefaultTimeZone" ] && [ ! -z "$TZ" ]; then
    export APP_UserDefaultTimeZone=$TZ
fi;

if [ ! -z "$APP_UserDefaultTimeZone" ]; then
    otrs.Console.pl Admin::Config::Update --setting-name 'UserDefaultTimeZone' --value "$APP_UserDefaultTimeZone" --no-deploy
fi;

if [ -z "$APP_OTRSTimeZone" ] && [ ! -z "$TZ" ]; then
    export APP_OTRSTimeZone=$TZ
fi;

if [ ! -z "$APP_UserDefaultTimeZone" ]; then
    otrs.Console.pl Admin::Config::Update --setting-name 'OTRSTimeZone' --value "$APP_OTRSTimeZone" --no-deploy
fi;
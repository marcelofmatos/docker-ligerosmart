#!/bin/bash

[[ -z "$APP_Cache_Redis_Server" ]] && exit 0

otrs.Console.pl Admin::Config::Update --setting-name "Cache::Module" --value "Kernel::System::Cache::Redis" --no-deploy
otrs.Console.pl Admin::Config::Update --setting-name "Cache::Redis###Server" --value "$APP_Cache_Redis_Server" --no-deploy

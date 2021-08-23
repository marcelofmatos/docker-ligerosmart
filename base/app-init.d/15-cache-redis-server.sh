#!/bin/bash

[[ -z "$CACHE_REDIS_SERVER" ]] && exit 0

otrs.Console.pl Admin::Config::Update --setting-name "Cache::Module" --value "Kernel::System::Cache::Redis" --no-deploy
otrs.Console.pl Admin::Config::Update --setting-name "Cache::Redis###Server" --value "$CACHE_REDIS_SERVER" --no-deploy

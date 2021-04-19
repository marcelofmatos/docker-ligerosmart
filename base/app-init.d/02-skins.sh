#!/bin/bash

# default skins
otrs.Console.pl Admin::Config::Update --setting-name 'Loader::Customer::SelectedSkin' --value 'ligero' --no-deploy
otrs.Console.pl Admin::Config::Update --setting-name 'Loader::Agent::DefaultSelectedSkin' --value 'ligero' --no-deploy

# Image Path
otrs.Console.pl Admin::Config::Update --setting-name 'Frontend::ImagePath' --value '<OTRS_CONFIG_Frontend::WebPath>skins/Agent/ligero/img/'  --no-deploy

# Login Logo
otrs.Console.pl Admin::Config::Update --setting-name AgentLoginLogo --source-path /app-init.d/AgentLoginLogo.yml --no-deploy

# Product Name
otrs.Console.pl Admin::Config::Update --setting-name 'ProductName' --value 'LigeroSmart'  --no-deploy
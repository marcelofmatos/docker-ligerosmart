#!/bin/bash

# create default customer company
otrs.Console.pl Admin::CustomerCompany::Add --customer-id "LIGEROSMART" --name "LigeroSmart" --street "AVENIDA BRIGADEIRO FARIA LIMA, 2369 - CJ 1103" --zip "01452-000" --city "São Paulo" --country "Brazil" --url "http://www.ligerosmart.com"

# set default company
otrs.Console.pl Admin::Config::Update --setting-name "CustomerHeadline" --value "" --no-deploy
otrs.Console.pl Admin::Config::Update --setting-name "Organization" --value "LigeroSmart" --no-deploy

#!/bin/bash

#  service mail integration with mailcatcher
otrs.Console.pl Admin::Config::Update --setting-name 'SendmailModule' --value 'Kernel::System::Email::SMTP' --no-deploy
otrs.Console.pl Admin::Config::Update --setting-name 'SendmailModule::Host' --value 'mail' --no-deploy
otrs.Console.pl Admin::Config::Update --setting-name 'CheckMXRecord' --value '0' --no-deploy
otrs.Console.pl Admin::Config::Update --setting-name 'CheckEmailAddresses' --value '0' --no-deploy

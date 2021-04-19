#!/bin/bash

otrs.Console.pl Admin::Config::Update --setting-name 'Ticket::Frontend::CustomerTicketMessage###QueueDefault' --value 'Raw' --valid 1 --no-deploy
otrs.Console.pl Admin::Config::Update --setting-name 'Ticket::Frontend::CustomerTicketMessage###Queue' --value 0  --no-deploy
otrs.Console.pl Admin::Config::Update --setting-name 'Ticket::Frontend::CustomerTicketMessage###SLA' --value 0  --no-deploy
otrs.Console.pl Admin::Config::Update --setting-name 'Ticket::Frontend::CustomerTicketMessage###ServiceMandatory' --value 1  --no-deploy
otrs.Console.pl Admin::Config::Update --setting-name 'Ticket::Frontend::CustomerTicketMessage###TicketType' --value 0  --no-deploy
otrs.Console.pl Admin::Config::Update --setting-name 'Ticket::Frontend::CustomerTicketMessage###TicketTypeDefault' --value 'Unclassified' --valid 1 --no-deploy
otrs.Console.pl Admin::Config::Update --setting-name 'Ticket::Frontend::CustomerTicketMessage###Priority' --value 0  --no-deploy
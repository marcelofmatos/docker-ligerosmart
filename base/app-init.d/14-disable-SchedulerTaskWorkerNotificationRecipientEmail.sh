#!/bin/bash
otrs.Console.pl Admin::Config::Update --setting-name Daemon::SchedulerTaskWorker::NotificationRecipientEmail --valid=0 --no-deploy

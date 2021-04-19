#!/usr/bin/env bash

if [ -f "$APP_DIR/.env" ]; then
    source "$APP_DIR/.env"
fi;

INITSCREEN_DIR=/var/www/html
PROGRESSBAR_FILE=$INITSCREEN_DIR/progress.txt

PACKAGE_LIST=`ls /app-packages/*.opm 2> /dev/null`
PACKAGE_COUNT=`ls -1 /app-packages/*.opm 2> /dev/null | wc -l`

MIGRATIONS_LIST=`find $APP_DIR/Kernel/Database/Migrations/ -type f 2> /dev/null | sort -n`
MIGRATIONS_COUNT=`find $APP_DIR/Kernel/Database/Migrations/ -type f 2> /dev/null | wc -l`

SCRIPT_LIST=`find /app-init.d/ -type f -executable 2> /dev/null | sort -n`
SCRIPT_COUNT=`find /app-init.d/ -type f -executable 2> /dev/null | wc -l`



if [ -d "$RESTORE_DIR" ]; then
    #
    # restore system from backup dir
    #
    echo "$0 - Restoring backup $RESTORE_DIR"

    echo "10" > $PROGRESSBAR_FILE

    otrs.Console.pl Maint::Cache::Delete

    cp Kernel/Config.pm{,_tmp}
    /opt/otrs/scripts/restore.pl -d /opt/otrs -b $RESTORE_DIR
    cp Kernel/Config.pm{,_restored}
    mv Kernel/Config.pm{_tmp,}

    export BACKUP_RESTORED=1

fi;

echo "20" > $PROGRESSBAR_FILE
let TOTAL_ITENS=$PACKAGE_COUNT+$MIGRATIONS_COUNT+$SCRIPT_COUNT
let PROGRESS_STEP=70/$TOTAL_ITENS

# migrations
otrs.Console.pl Maint::Database::Migration::TableCreate
echo "$0 - running migrations"
for MIGRATION_FILE in $MIGRATIONS_LIST; do
    otrs.Console.pl Maint::Database::Migration::Apply $MIGRATION_FILE
    let ITEM_COUNT+=1
    let PROGRESS=$PROGRESS_STEP*$ITEM_COUNT+20
    echo $PROGRESS > $PROGRESSBAR_FILE
done;

# initial config
otrs.Console.pl Maint::Config::Rebuild
otrs.Console.pl Admin::Config::Update --setting-name 'Package::AllowNotVerifiedPackages' --value 1 --no-deploy
[ $APP_DefaultLanguage ] && otrs.Console.pl Admin::Config::Update --setting-name 'DefaultLanguage' --value $APP_DefaultLanguage --no-deploy
# TODO: loop on APP_* testing setting name
otrs.Console.pl Maint::Config::Rebuild

# install packages
for PKG in $PACKAGE_LIST; do
    echo "$0 - Installing package $PKG"
    otrs.Console.pl Admin::Package::Install --force --quiet $PKG 
    let ITEM_COUNT+=1
    let PROGRESS=$PROGRESS_STEP*$ITEM_COUNT+20
    echo $PROGRESS > $PROGRESSBAR_FILE
done;


# run custom init scripts
for f in $SCRIPT_LIST; do
    echo "$0 - running $f"
    $f
    let ITEM_COUNT+=1
    let PROGRESS=$PROGRESS_STEP*$ITEM_COUNT+30
    echo $PROGRESS > $PROGRESSBAR_FILE
done

echo "90" > $PROGRESSBAR_FILE


# root password
otrs.Console.pl Admin::User::SetPassword 'root@localhost' ${ROOT_PASSWORD:-ligero}
echo "default user: root@localhost"
if [ "$ROOT_PASSWORD" == "ligero" ]; then
    echo "default password: ligero"
else
    echo "root@localhost password changed"
fi;

unset ROOT_PASSWORD

# enable secure mode
otrs.Console.pl Admin::Config::Update --setting-name SecureMode --value 1 --no-deploy

# apply config
otrs.Console.pl Maint::Config::Rebuild

otrs.Console.pl Maint::Log::Clear

echo "98" > $PROGRESSBAR_FILE

exit 0
#!/bin/bash
# Requirements
# - NICE
# - IONICE (liblinux-io-prio-perl no debian)

. /etc/ligero-backup.conf

BACKUP_PREFFIX="partialbackup_"
NAME="${BACKUP_PREFFIX}`(date +%Y-%m-%d_%H-%M)`"
TMP_BKP_DIR="$BACKUP_DIR/$NAME/tmp/"

mkdir -p $TMP_BKP_DIR

# DON'T EXPORT DATA FROM THOSE TABLES
IGNORED_TABLES_STRING=''
for TABLE in "${EXCLUDED_TABLES[@]}"
do :
   IGNORED_TABLES_STRING+=" --ignore-table=${DATABASE}.${TABLE}"
done

IGNORED_YEARS_STRING=''
for YEAR in "${EXCLUDED_YEARS[@]}"
do :
   IGNORED_YEARS_STRING+=" --exclude=${PASTA_OTRS}/var/article/${YEAR} "
done

START=`(date +%H:%M:%S\ %Y-%m-%d)`
echo "Backup started at $START"
echo "Cleaning temporary backup directory..."

rm $TMP_BKP_DIR/* -rf

echo "Copying Config.pm..."
mkdir -p $TMP_BKP_DIR/otrs/Kernel
cp /opt/otrs/Kernel/Config.pm $TMP_BKP_DIR/otrs/Kernel
echo "Done"

echo "Copying Config folder..."
cp /opt/otrs/Kernel/Config $TMP_BKP_DIR/otrs -R
echo "Done"

mkdir $TMP_BKP_DIR/otrs/var

sleep $DELAY
echo "Cleaning Cache Files before Copying them..."
su -c "${DELETE_CACHE}" -s /bin/bash otrs

sleep $DELAY
echo "Copying important var folders..."
cp /opt/otrs/var/log $TMP_BKP_DIR/otrs/var -R
cp /opt/otrs/var/run $TMP_BKP_DIR/otrs/var -R
cp /opt/otrs/var/sessions $TMP_BKP_DIR/otrs/var -R
cp /opt/otrs/var/spool $TMP_BKP_DIR/otrs/var -R
cp /opt/otrs/var/stats $TMP_BKP_DIR/otrs/var -R
cp /opt/otrs/var/tmp $TMP_BKP_DIR/otrs/var -R
echo "Done"

sleep $DELAY
mkdir $TMP_BKP_DIR/otrs/var/article
echo "Copying last $PARTIAL_DAYS day(s) articles..."
for ((i=0; i<=$PARTIAL_DAYS; i++))
do
    CAMINHO=`(date +%Y/%m/%d -d "$i day ago")`
    YEAR=`(date +%Y -d "$i day ago")`
    MONTH=`(date +%m -d "$i day ago")`
    ARTICLE_DIR_TO_CP=$TMP_BKP_DIR/otrs/var/article/$YEAR/$MONTH
    [[ ! -d "/opt/otrs/var/article/$CAMINHO" ]] && echo "$CAMINHO not found" && continue
    mkdir -p $ARTICLE_DIR_TO_CP
    nice -n 10 ionice -c2 -n7 cp /opt/otrs/var/article/$CAMINHO $ARTICLE_DIR_TO_CP -R
    echo "Day $i done"
    sleep $DELAY
done
echo "Last $PARTIAL_DAYS day(s) articles copied."

echo "Dumping Database..."
if [[ $APP_DatabaseType == 'mysql' ]]; then
    nice -n 10 ionice -c2 -n7 mysqldump -u $DatabaseUser -h $DatabaseHost -p$DatabasePw $Database > $TMP_BKP_DIR/DatabaseBackup.sql
fi;
if [[ $APP_DatabaseType == 'postgresql' ]]; then
    nice -n 10 ionice -c2 -n7 pg_dump -C -U $DatabaseUser -h $DatabaseHost $Database > $TMP_BKP_DIR/DatabaseBackup.sql
fi;
echo "Done"

sleep $DELAY
echo "Compressing files..."
nice -n 10 ionice -c2 -n7 tar jcpf /app-backups/$NAME/DatabaseBackup.sql.bz2 -C $TMP_BKP_DIR/ DatabaseBackup.sql
nice -n 10 ionice -c2 -n7 tar jcpf /app-backups/$NAME/Application.tar.bz2 -C $TMP_BKP_DIR/otrs .
echo "Done"

#echo "Moving to destination folder..."
#cp $TMP_BKP_DIR/partial-otrs-backup.$NAME-$EMPRESA.tar.bz2 $DESTINATION_FOLDER
#echo "Done"

echo "Removing temporary files..."
rm -rf $TMP_BKP_DIR
echo "Done"

END=`(date +%H:%M:%S\ %Y-%m-%d)`
echo "Partial Backup is done at $END!"


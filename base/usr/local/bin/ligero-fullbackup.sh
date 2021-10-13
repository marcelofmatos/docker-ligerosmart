#!/bin/bash
# Requirements
# - NICE
# - IONICE (liblinux-io-prio-perl no debian)

. /etc/ligero-backup.conf

BACKUP_PREFFIX="fullbackup_"
NAME="${BACKUP_PREFFIX}`(date +%Y-%m-%d_%H-%M)`"
TMP_BKP_DIR="$BACKUP_DIR/$NAME/tmp/"
CompressType=${CompressType:-gzip}

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

IGNORED_PATHS_STRING=''
for EXCLUDED_PATH in "${EXCLUDED_BACKUP_PATHS[@]}"
do :
   IGNORED_PATHS_STRING+=" --exclude=${EXCLUDED_PATH} "
done

START=`(date +%H:%M:%S\ %Y-%m-%d)`
echo "Backup started at $START"

echo "Dumping Database..."
if [ $APP_DatabaseType == 'mysql' ]; then
    nice -n 10 ionice -c2 -n7 mysqldump -u $DatabaseUser -h $DatabaseHost -p$DatabasePw $Database > $TMP_BKP_DIR/DatabaseBackup.sql
fi;
if [ $APP_DatabaseType == 'postgresql' ]; then
    nice -n 10 ionice -c2 -n7 pg_dump -C -U $DatabaseUser -h $DatabaseHost $Database > $TMP_BKP_DIR/DatabaseBackup.sql
fi;
echo "Done"

sleep $DELAY
echo "Compressing files..."
case $CompressType in
    bz2)
        nice -n 10 ionice -c2 -n7 tar jcpf /app-backups/$NAME/DatabaseBackup.sql.bz2 -C $TMP_BKP_DIR/ DatabaseBackup.sql
        nice -n 10 ionice -c2 -n7 tar jcpf /app-backups/$NAME/Application.tar.bz2 -C /opt/otrs $IGNORED_PATHS_STRING .
        ;;
    gzip)
        nice -n 10 ionice -c2 -n7 tar zcpf /app-backups/$NAME/DatabaseBackup.sql.gz -C $TMP_BKP_DIR/ DatabaseBackup.sql
        nice -n 10 ionice -c2 -n7 tar zcpf /app-backups/$NAME/Application.tar.gz -C /opt/otrs $IGNORED_PATHS_STRING .
        ;;
esac
echo "Done"

#set permissions to otrs user
if [ "$USER" == "root" ]; then
    chown otrs:www-data -R /app-backups/$NAME
fi

echo "Removing temporary files..."
rm $TMP_BKP_DIR -rf
echo "Done"

END=`(date +%H:%M:%S\ %Y-%m-%d)`
echo "Full Backup is done at $END!"

#!/bin/bash
# Instructions
# - Place this script under /opt/complemento/backup
# - it must be in this place
# Requirements
# - NICE
# - IONICE (liblinux-io-prio-perl no debian)
# - awscli (installed and confgiured)

. /etc/backupComplementoS3.conf

TMP_BKP_DIR="$BACKUP_DIR/tmp/"

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
    mkdir -p $TMP_BKP_DIR/otrs/var/article/$YEAR/$MONTH
    nice -n 10 ionice -c2 -n7 cp /opt/otrs/var/article/$CAMINHO $TMP_BKP_DIR/otrs/var/article/$YEAR/$MONTH -R
    echo "Day $i done"
    sleep $DELAY
done
echo "Last $PARTIAL_DAYS day(s) articles copied."

echo "Dumping Database..."
nice -n 10 ionice -c2 -n7 pg_dump -C -U $DatabaseUser -h $DatabaseHost $Database > $TMP_BKP_DIR/DatabaseBackup.sql
echo "Done"


sleep $DELAY
echo "Compressing files..."
NAME=`(date +%Y-%m-%d_%H-%M)`
nice -n 10 ionice -c2 -n7 tar jcpf $TMP_BKP_DIR/partial-otrs-backup.$NAME-$EMPRESA.tar.bz2 -C $TMP_BKP_DIR/ DatabaseBackup.sql -C $TMP_BKP_DIR/otrs .
echo "Done"

#echo "Moving to destination folder..."
#cp $TMP_BKP_DIR/partial-otrs-backup.$NAME-$EMPRESA.tar.bz2 $DESTINATION_FOLDER
#echo "Done"

echo "Sending partial backup to AWS S3..."
for PROFILE in "${AWS_PROFILES[@]}"
do :
    aws s3 cp $TMP_BKP_DIR/partial-otrs-backup.$NAME-$EMPRESA.tar.bz2 s3://$BUCKET/ --profile ${PROFILE}
done

echo "Done"

echo "Removing temporary files..."
rm $TMP_BKP_DIR/* -rf
echo "Done"

echo "Removing Old Partial Backups from S3..."
# get the date X days ago
DaysAgo=$(date -d "-${PARTIAL_KEEP} day 00:00:00" +%s)
# create an array to hold the files older than 7 days
for PROFILE in "${AWS_PROFILES[@]}"
do :
    for file in $(aws s3 ls s3://$BUCKET --profile ${PROFILE} | awk '{print $4}'); do
        # extract the date from each filename using a regex
        if [[ $file =~ ^partial-otrs-backup.*\.([0-9]+)-([0-9]+)-([0-9]+)_.*$ ]]
        then
            y="${BASH_REMATCH[1]}"
            m="${BASH_REMATCH[2]}"
            d="${BASH_REMATCH[3]}"
            fileDateTime="$(date -d ${y}${m}${d} +%s)"
            
            # check if the date is older than 7 days ago
            if (( fileDateTime < DaysAgo ))
            then
            	echo "Removing s3://$BUCKET/$file" 
		        aws s3 rm s3://$BUCKET/$file --profile ${PROFILE}
            fi
        fi

    done
done

END=`(date +%H:%M:%S\ %Y-%m-%d)`
echo "Partial Backup is done at $END!"


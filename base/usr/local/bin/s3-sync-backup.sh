#!/bin/bash

. /etc/ligero-backup.conf

if [ ! -f ~/.aws/credentials ]; then
    echo "configure your aws cli with 'aws configure'"
    exit 1
fi;

if [ -z $BUCKET ]; then
    echo "BUCKET name is empty"
    exit 1
fi;

echo "Sending full backup to AWS S3..."
for PROFILE in "${AWS_PROFILES[@]}"
do :
    aws s3 sync /app-backups/$NAME/ s3://$BUCKET/$NAME/ --profile ${PROFILE} --exclude="*" --include "*.bz2" 
done
echo "Done"


echo "Removing Old Full Backups from S3..."
# get the date X days ago
DaysAgo=$(date -d "-${FULL_KEEP} day 00:00:00" +%s)
# create an array to hold the files older than 7 days

for PROFILE in "${AWS_PROFILES[@]}"
do :
    for file in $(aws s3 ls s3://$BUCKET --profile ${PROFILE} | awk '{print $4}'); do
        # extract the date from each filename using a regex
        if [[ $file =~ ^${BACKUP_PREFFIX}([0-9]+)-([0-9]+)-([0-9]+)_.*$ ]]
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

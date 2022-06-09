#!/bin/bash
# adding backup mysql scripts
echo "wget https://raw.githubusercontent.com/clusterednetworks/backup-mysql/master/backup-mysql.sh"

# concatenate and edit the vim backup mysql file
vi backup-mysql.sh

----------------------------------------
 OPTIONS
----------------------------------------
USER='justineabria'       # MySQL User
PASSWORD='just30' # MySQL Password
DAYS_TO_KEEP=5    # 0 to keep forever
GZIP=0            # 1 = Compress
BACKUP_PATH='/home/backup/mysql'
#----------------------------------------

# Create the backup folder
if [ ! -d $BACKUP_PATH ]; then
  mkdir -p $BACKUP_PATH
fi

# Get list of database names
databases=`mysql -u $USER -p$PASSWORD -e "SHOW DATABASES;" | tr -d "|" | grep -v Database`

for db in $databases; do

  if [ $db == 'information_schema' ] || [ $db == 'performance_schema' ] || [ $db == 'mysql' ] || [ $db == 'sys' ]; then
    echo "Skipping database: $db"
    continue
  fi

  date=$(date -I)
  if [ "$GZIP" -eq 0 ] ; then
    echo "Backing up database: $db without compression"
    mysqldump -u $USER -p$PASSWORD --databases $db > $BACKUP_PATH/$date-$db.sql
    
  else
    echo "Backing up database: $db with compression"
    mysqldump -u $USER -p$PASSWORD --databases $db | gzip -c > $BACKUP_PATH/$date-$db.gz
  fi
done

# Delete old backups
if [ "$DAYS_TO_KEEP" -gt 0 ] ; then
  echo "Deleting backups older than $DAYS_TO_KEEP days"
  find $BACKUP_PATH/* -mtime +$DAYS_TO_KEEP -exec rm {} \;
fi

# make the script executable
chmod +x backup-mysql.sh

# run the script
./backup-mysql.sh

# add all changes to the git server
git add -A

# commit changes added to the git and add a message
git commit -m "added abria_wordpress_MMDDYYY.sql.sh"

# upload the script to github
git push origin main






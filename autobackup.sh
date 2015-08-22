#!/bin/sh
# PATH=/opt/someApp/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

DATE_ALL=`date +%Y-%m-%d_%H.%M.%S`

# test
# echo "$DATE_YEAR/$DATE_MONTH ..." > $DATE_YEAR-$DATE_MONTH-$DATE自动备份.txt

cd /data/sites/laiblog/

# backuo ghost.db
git add /data/sites/laiblog/content/data/ghost.db

git commit -m "auto backup"

git push

git tag -a v$DATE_ALL -m 'auto backup'

git push origin v$DATE_ALL:v$DATE_ALL






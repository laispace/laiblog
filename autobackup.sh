#!/bin/sh
# PATH=/opt/someApp/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

DATE_ALL=`date +%Y-%m-%d_%H.%M.%S`

# test
# echo "$DATE_YEAR/$DATE_MONTH ..." > $DATE_YEAR-$DATE_MONTH-$DATE自动备份.txt

cd /data/laiblog/

# 线上服务器仅备份 ghost.db 数据库
git add content/data/ghost.db

git commit -m "ghost.db 自动备份"

git push

git tag -a v$DATE_ALL -m 'ghost.db 自动备份'

git push origin v$DATE_ALL:v$DATE_ALL






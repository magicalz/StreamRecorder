#!/bin/bash
#usage: $0 [name|all] [youtube|bilibili|twitch|twitcast]
NAME="${1:-all}"
SITE="$2"
SERVERNAME=$(grep "Servername" ./config/config.global|awk -F = '{print $2}')
SAVEFOLDER=$(grep "Savefolder" ./config/config.global|awk -F = '{print $2}')
[[ ! -d "log" ]]&&mkdir log
LOG_PREFIX=$(date +"[%Y-%m-%d-%H]")
echo "$LOG_PREFIX rclone begin to backup files"
echo "$LOG_PREFIX check ./log/rclone_${LOG_PREFIX}.log for detail"
if [ "$NAME" == "all" ]
then
  rclone copy --no-traverse "$SAVEFOLDER" magicalz:${SERVERNAME}/stream-recorder/${SAVEFOLDER} --include-from rcloneinclude.txt --buffer-size 32M --transfers 6 --low-level-retries 200 -v > "./log/rclone_${LOG_PREFIX}.log" 2>&1
elif [ -z "$SITE" ]
then
  rclone copy --no-traverse "${SAVEFOLDER}/${NAME}" magicalz:${SERVERNAME}/stream-recorder/${SAVEFOLDER}/${NAME} --include-from rcloneinclude.txt --buffer-size 32M --transfers 6 --low-level-retries 200 -v > "./log/rclone_${LOG_PREFIX}.log" 2>&1
else
  rclone copy --no-traverse "${SAVEFOLDER}/${NAME}/${SITE}" magicalz:${SERVERNAME}/stream-recorder/${SAVEFOLDER}/${NAME}/${SITE} --include-from rcloneinclude.txt --buffer-size 32M --transfers 6 --low-level-retries 200 -v > "./log/rclone_${LOG_PREFIX}.log" 2>&1  
fi
if grep -q "Copied (new)" ./log/rclone_${LOG_PREFIX}.log
then
  echo "$LOG_PREFIX rclone backup complete" 
  if [ -z "$(screen -ls|grep baidu)" ]
  then 
    echo "$LOG_PREFIX begin to clean files"
    ./clean.sh $NAME $SITE
  else
    echo "$LOG_PREFIX skip clean...BadiduPCS backup stilling running" 
  fi
else
  echo "$LOG_PREFIX skip clean...rclone backup failed, check ./log/rclone_${LOG_PREFIX}.log for detail"
fi

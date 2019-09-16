#!/bin/bash
#usage: $0 [name|all] [youtube|bilibili|twitch|twitcast] [folderbydate] [filename]
NAME="${1:-all}"
SITE="$2"
SERVERNAME=$(grep "Servername" ./config/config.global|awk -F = '{print $2}')
SAVEFOLDER=$(grep "Savefolder" ./config/config.global|awk -F = '{print $2}')
REMOTENAME=$(grep "Rcloneremotename" ./config/config.global|awk -F = '{print $2}')
TARGETPATH="${REMOTENAME}:${SERVERNAME}/stream-recorder/${SAVEFOLDER}"
[ "$NAME" != "all" ] && SAVEFOLDER="$SAVEFOLDER/$NAME" && TARGETPATH="$TARGETPATH/$NAME"
[ -n "$SITE" ] && SAVEFOLDER="$SAVEFOLDER/$SITE" && TARGETPATH="$TARGETPATH/$SITE"
[ -n "$3" ] && SAVEFOLDER="$SAVEFOLDER/$3" && TARGETPATH="$TARGETPATH/$3" 
LOG_PREFIX=$(date +"[%Y-%m-%d %H:%M:%S]")
LOG_SUFFIX=$(date +"%Y%m%d_%H%M%S")
echo "$LOG_PREFIX ===rclonebackup=== rclone begin to backup files"
echo "$LOG_PREFIX ===rclonebackup=== check ./log/rclone_${LOG_SUFFIX}.log for detail"
if [ -n "$4" ]
then
  FILENAME=$(echo "$4"|awk -F . '{print $1}')
  rclone copy --no-traverse "$SAVEFOLDER" "$TARGETPATH" --include "$FILENAME.*" --buffer-size 32M --transfers 6 --low-level-retries 200 -v > "./log/rclone_${LOG_SUFFIX}.log" 2>&1
else
  rclone copy --no-traverse "$SAVEFOLDER" "$TARGETPATH" --include-from rcloneinclude.txt --buffer-size 32M --transfers 6 --low-level-retries 200 -v > "./log/rclone_${LOG_SUFFIX}.log" 2>&1
fi
if ! grep -q "ERROR" ./log/rclone_${LOG_SUFFIX}.log && grep -q "Copied (new)" ./log/rclone_${LOG_SUFFIX}.log
then
  echo "$LOG_PREFIX ===rclonebackup=== rclone backup complete" 
  if [ "$NAME" == "all" ]
  then
    BAIDU_PROCESS=$(screen -ls|grep baidu)
  else
    BAIDU_PROCESS=$(screen -ls|grep baidu|grep $NAME)
  fi
  if [ -z "$BAIDU_PROCESS" ]
  then 
    echo "$LOG_PREFIX ===rclonebackup=== begin to clean files"
    ./autoclean.sh $NAME $SITE $3 $4
  else
    echo "$LOG_PREFIX ===rclonebackup=== skip clean...BadiduPCS backup stilling running"
    echo "$BAIDU_PROCESS" 
  fi
else
  echo "$LOG_PREFIX ===rclonebackup=== skip clean...rclone backup failed, check ./log/rclone_${LOG_SUFFIX}.log for detail"
fi

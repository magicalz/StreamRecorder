#!/bin/bash
#usage: $0 [name|all] [youtube|bilibili|twitch|twitcast] [folderbydate] [filename]

NAME="${1:-all}"
SITE="$2"
SERVERNAME=$(grep "Servername" ./config/config.global|awk -F = '{print $2}')
SAVEFOLDER=$(grep "Savefolder" ./config/config.global|awk -F = '{print $2}')
TARGETPATH="/stream-recorder/$SERVERNAME"
[ "$NAME" != "all" ] && TARGETPATH="$TARGETPATH/$SAVEFOLDER" && SAVEFOLDER="$SAVEFOLDER/$NAME"
[ -n "$SITE" ] && TARGETPATH="$TARGETPATH/$NAME" && SAVEFOLDER="$SAVEFOLDER/$SITE"
[ -n "$3" ] && TARGETPATH="$TARGETPATH/$SITE" && SAVEFOLDER="$SAVEFOLDER/$3"
[ -n "$4" ] && FILENAME=$(echo "$4"|awk -F . '{print $1}') && TARGETPATH="$TARGETPATH/$3" && SAVEFOLDER="$SAVEFOLDER/$FILENAME.*" 
LOG_PREFIX=$(date +"[%Y-%m-%d %H:%M:%S]")
LOG_SUFFIX=$(date +"%Y%m%d_%H%M%S")
echo "$LOG_PREFIX ===baidubackup=== BaiduPCS begin to backup files"
echo "$LOG_PREFIX ===baidubackup=== check ./log/BaiduPCS_${LOG_SUFFIX}.log for detail"
BaiduPCS-Go upload "$SAVEFOLDER" "$TARGETPATH" > "./log/BaiduPCS_${LOG_SUFFIX}.log" 2>&1
if grep -q -E "上传文件失败|全部上传完毕, 总大小: 0B" ./log/BaiduPCS_${LOG_SUFFIX}.log
then
  echo "$LOG_PREFIX ===baidubackup=== skip clean...BaiduPCS backup failed, check ./log/BaiduPCS_${LOG_SUFFIX}.log for detail"
else  
  echo "$LOG_PREFIX ===baidubackup=== BaiduPCS backup complete"
  if [ "$NAME" == "all" ]
  then
    RCLONE_PROCESS=$(screen -ls|grep rclone)
  else
    RCLONE_PROCESS=$(screen -ls|grep rclone|grep $NAME)
  fi
  if [ -z "$RCLONE_PROCESS" ]
  then
    echo "$LOG_PREFIX ===baidubackup=== begin to clean files"
    ./autoclean.sh $NAME $SITE $3 $4
  else
    echo "$LOG_PREFIX ===baidubackup=== skip...rclone backup stilling running"
    echo "$RCLONE_PROCESS"  
  fi
fi

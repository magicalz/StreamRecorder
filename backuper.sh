#!/bin/bash
#usage: $0 [backupmethod] [name|all] [youtube|bilibili|twitch|twitcast] [folderbydate] [filename]

BACKUPMETHOD="${1:-rclone}"
NAME="${2:-all}"
SITE="$3"
FOLDERBYDATE="$4"
FILENAME="$5"
SERVERNAME=$(grep "Servername" ./config/global.config|awk -F = '{print $2}')
SAVEFOLDER=$(grep "Savefolder" ./config/global.config|awk -F = '{print $2}')
REMOTENAME=$(grep "Rcloneremotename" ./config/global.config|awk -F = '{print $2}')
LOG_PREFIX=$(date +"[%Y-%m-%d %H:%M:%S]")
LOG_SUFFIX=$(date +"%Y%m%d_%H%M%S")
if [ "$BACKUPMETHOD" == "baidu" ] || [ "$BACKUPMETHOD" == "both" ]
then
  TARGETPATH="/StreamRecorder/$SERVERNAME"
  [ "$NAME" != "all" ] && TARGETPATH="$TARGETPATH/$SAVEFOLDER" && SAVEFOLDER="$SAVEFOLDER/$NAME"
  [ -n "$SITE" ] && TARGETPATH="$TARGETPATH/$NAME" && SAVEFOLDER="$SAVEFOLDER/$SITE"
  [ -n "$FOLDERBYDATE" ] && TARGETPATH="$TARGETPATH/$SITE" && SAVEFOLDER="$SAVEFOLDER/$FOLDERBYDATE"
  [ -n "$FILENAME" ] && FILENAME=$(echo "$FILENAME"|awk -F . '{print $1}') && TARGETPATH="$TARGETPATH/$FOLDERBYDATE" && SAVEFOLDER="$SAVEFOLDER/$FILENAME.*"
  echo "$LOG_PREFIX ===baidubackup=== BaiduPCS begin to backup files"
  echo "$LOG_PREFIX ===baidubackup=== check ./log/BaiduPCS_${LOG_SUFFIX}.log for detail"
  BaiduPCS-Go upload "$SAVEFOLDER" "$TARGETPATH" > "./log/BaiduPCS_${LOG_SUFFIX}.log" 2>&1
fi
if [ "$BACKUPMETHOD" == "rclone" ] || [ "$BACKUPMETHOD" == "both" ]
then
  TARGETPATH="${REMOTENAME}:StreamRecorder/${SERVERNAME}/${SAVEFOLDER}"
  [ "$NAME" != "all" ] && SAVEFOLDER="$SAVEFOLDER/$NAME" && TARGETPATH="$TARGETPATH/$NAME"
  [ -n "$SITE" ] && SAVEFOLDER="$SAVEFOLDER/$SITE" && TARGETPATH="$TARGETPATH/$SITE"
  [ -n "$FOLDERBYDATE" ] && SAVEFOLDER="$SAVEFOLDER/$FOLDERBYDATE" && TARGETPATH="$TARGETPATH/$FOLDERBYDATE"
  echo "$LOG_PREFIX ===rclonebackup=== rclone begin to backup files"
  echo "$LOG_PREFIX ===rclonebackup=== check ./log/rclone_${LOG_SUFFIX}.log for detail"
  if [ -n "$FILENAME" ]
  then
    FILENAME=$(echo "$FILENAME"|awk -F . '{print $1}')
    rclone copy --no-traverse "$SAVEFOLDER" "$TARGETPATH" --include "$FILENAME.*" --buffer-size 32M --transfers 6 --low-level-retries 200 -v > "./log/rclone_${LOG_SUFFIX}.log" 2>&1
  else
    rclone copy --no-traverse "$SAVEFOLDER" "$TARGETPATH" --include-from rcloneinclude.txt --buffer-size 32M --transfers 6 --low-level-retries 200 -v > "./log/rclone_${LOG_SUFFIX}.log" 2>&1
  fi
fi

[ "$BACKUPMETHOD" == "baidu" ] || [ "$BACKUPMETHOD" == "both" ] && ! grep -q -E "上传文件失败|全部上传完毕, 总大小: 0B" ./log/BaiduPCS_${LOG_SUFFIX}.log && BAIDUSUCCESS="SUCCESS"
[ "$BACKUPMETHOD" == "rclone" ] || [ "$BACKUPMETHOD" == "both" ] && ! grep -q "error" ./log/rclone_${LOG_SUFFIX}.log && grep -q "Copied (new)" ./log/rclone_${LOG_SUFFIX}.log && RCLONESUCCESS="SUCCESS"
if ([ "$BACKUPMETHOD" == "baidu" ] && [ "$BAIDUSUCCESS" == "SUCCESS" ]) || ([ "$BACKUPMETHOD" == "rclone" ] && [ "$RCLONESUCCESS" == "SUCCESS" ]) || ([ "$BACKUPMETHOD" == "both" ] && [ "$BAIDUSUCCESS" == "SUCCESS" ] && [ "$RCLONESUCCESS" == "SUCCESS" ])
then
  echo "$LOG_PREFIX ===backup=== backup complete, begin to clean files" 
  ./autoclean.sh $NAME $SITE $FOLDERBYDATE $FILENAME
else
  [ "$BACKUPMETHOD" == "baidu" ] || [ "$BACKUPMETHOD" == "both" ] && [ "$BAIDUSUCCESS" != "SUCCESS" ] && echo "$LOG_PREFIX ===baidubackup=== skip clean...BaiduPCS backup failed, check ./log/BaiduPCS_${LOG_SUFFIX}.log for detail"
  [ "$BACKUPMETHOD" == "rclone" ] || [ "$BACKUPMETHOD" == "both" ] && [ "$RCLONESUCCESS" != "SUCCESS" ] && echo "$LOG_PREFIX ===rclonebackup=== skip clean...rclone backup failed, check ./log/rclone_${LOG_SUFFIX}.log for detail"
fi


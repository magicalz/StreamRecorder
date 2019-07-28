#!/bin/bash
#usage: $0 [name|all] [youtube|bilibili|twitch|twitcast]

NAME="${1:-all}"
SITE="$2"
SERVERNAME=$(grep "Servername" ./config/config.global|awk -F = '{print $2}')
SAVEFOLDER=$(grep "Savefolder" ./config/config.global|awk -F = '{print $2}')
LOG_PREFIX=$(date +"[%Y-%m-%d-%H]")
[[ ! -d "log" ]]&&mkdir log
echo "$LOG_PREFIX BaiduPCS begin to backup files"
echo "$LOG_PREFIX check ./log/BaiduPCS_${LOG_PREFIX}.log for detail"
if [ "$NAME" == "all" ]
then
  BaiduPCS-Go upload "$SAVEFOLDER" "/stream-recorder/${SERVERNAME}" > "./log/BaiduPCS_${LOG_PREFIX}.log" 2>&1
elif [ -z "$SITE" ]
then
  BaiduPCS-Go upload "${SAVEFOLDER}/${NAME}" "/stream-recorder/${SERVERNAME}/${SAVEFOLDER}" > "./log/BaiduPCS_${LOG_PREFIX}.log" 2>&1
else
  BaiduPCS-Go upload "${SAVEFOLDER}/${NAME}/${SITE}" "/stream-recorder/${SERVERNAME}/${SAVEFOLDER}/${NAME}" > "./log/BaiduPCS_${LOG_PREFIX}.log" 2>&1
fi
if grep -q -E "上传文件失败|全部上传完毕, 总大小: 0B" ./log/BaiduPCS_${LOG_PREFIX}.log
then
  echo "$LOG_PREFIX skip clean...BaiduPCS backup failed, check ./log/BaiduPCS_${LOG_PREFIX}.log for detail"
else  
  echo "$LOG_PREFIX BaiduPCS backup complete"
  if [ -z "$(screen -ls|grep rclone)" ]
  then
    echo "$LOG_PREFIX begin to clean files"
    ./clean.sh $NAME $SITE
  else
    echo "$LOG_PREFIX skip...rclone backup stilling running"  
  fi
fi

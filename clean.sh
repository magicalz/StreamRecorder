#!/bin/bash
if [ -z "$1" ]
then
  echo "usage: $0 [all|name] [youtube|bilibili|twitch|twitcast]"
  exit 1
fi
if [ "$1" == "all" ] && [ -n "$2" ]
then
  echo "wrong parameter, only accept all|name or name site, not accept all site"
  echo "usage: $0 [all|name] [youtube|bilibili|twitch|twitcast]"
  exit 1
fi
NAME="${1:-all}"
SITE="$2"
if [ "$NAME" == "all" ]
then
  STREAMLINK_PROCESS=$(ps -efwww|grep streamlink|grep -v 'grep')
  FFMPEG_PROCESS=$(ps -efwww|grep ffmpeg|grep -v 'grep')
  BAIDUPCS_PROCESS=$(ps -ef|grep 'BaiduPCS-Go upload'|grep -v 'grep')
  RCLONE_PROCESS=$(ps -ef|grep 'rclone copy'|grep -v 'grep')
else
  STREAMLINK_PROCESS=$(ps -efwww|grep streamlink|grep $NAME|grep -v 'grep')
  FFMPEG_PROCESS=$(ps -efwww|grep ffmpeg|grep $NAME|grep -v 'grep')
  BAIDUPCS_PROCESS=$(ps -ef|grep 'BaiduPCS-Go upload'|grep $NAME|grep -v 'grep')
  RCLONE_PROCESS=$(ps -ef|grep 'rclone copy'|grep $NAME|grep -v 'grep')
fi
SAVEFOLDER=$(grep "Savefolder" ./config/config.global|awk -F = '{print $2}')
[ "$NAME" != "all" ] && SAVEFOLDER="${SAVEFOLDER}/${NAME}"
[ -n "$SITE" ] && SAVEFOLDER="${SAVEFOLDER}/${SITE}"
LOG_PREFIX=$(date +"[%Y-%m-%d %H:%M:%S]")
LOG_SUFFIX=$(date +"%Y%m%d_%H%M%S")
echo "$LOG_PREFIX check ./log/clean_$LOG_SUFFIX.log for detail"
#check if download or upload is running
if [ -z "$STREAMLINK_PROCESS" ] && [ -z "$FFMPEG_PROCESS" ] && [ -z "$BAIDUPCS_PROCESS" ] && [ -z "$RCLONE_PROCESS" ]
then
  echo "$LOG_PREFIX below files will be delete:" >> "./log/clean_${LOG_SUFFIX}.log"
  find $SAVEFOLDER -maxdepth 4 -name "*.*" -size 0 -type f -exec ls -l {} \; >> "./log/clean_${LOG_SUFFIX}.log" 2>&1
  find $SAVEFOLDER -maxdepth 4 -name "*.*" -size 0 -type f -delete ; >> "./log/clean_${LOG_SUFFIX}.log" 2>&1
  find $SAVEFOLDER -maxdepth 4 -name "*.ts" -type f -exec ls -l {} \; >> "./log/clean_${LOG_SUFFIX}.log" 2>&1
  find $SAVEFOLDER -maxdepth 4 -name "*.ts" -type f -delete ; >> "./log/clean_${LOG_SUFFIX}.log" 2>&1
  find $SAVEFOLDER -maxdepth 4 -name "*.info.txt" -type f -exec ls -l {} \; >> "./log/clean_${LOG_SUFFIX}.log" 2>&1
  find $SAVEFOLDER -maxdepth 4 -name "*.info.txt" -type f -delete >> "./log/clean_${LOG_SUFFIX}.log" 2>&1
  if [ -d ~/.cache/rclone ]; then
    find ~/.cache/rclone -maxdepth 9 -name "*.*"   -type f -exec ls -l {} \; >> "./log/clean_${LOG_SUFFIX}.log" 2>&1
    rm -rf ~/.cache/rclone
  fi
elif [ -n "$STREAMLINK_PROCESS" ] || [ -n "$FFMPEG_PROCESS" ]
then
  echo "$LOG_PREFIX skip...stream download is in progress:" >> "./log/clean_${LOG_SUFFIX}.log"
  echo "$STREAMLINK_PROCESS" >> "./log/clean_${LOG_SUFFIX}.log"
  echo "$FFMPEG_PROCESS" >> "./log/clean_${LOG_SUFFIX}.log"
elif [ -n "$BAIDUPCS_PROCESS" ] || [ -n "$RCLONE_PROCESS" ]
then
  echo "$LOG_PREFIX skip...stream upload is in progress:" >> "./log/clean_${LOG_SUFFIX}.log"
  echo "$BAIDUPCS_PROCESS" >> "./log/clean_${LOG_SUFFIX}.log"
  echo "$RCLONE_PROCESS" >> "./log/clean_${LOG_SUFFIX}.log"
fi

#!/bin/bash
if [ -z "$1" ]
then
  echo "usage: $0 [all|name] [youtube|bilibili|twitch|twitcast] [folderbydate] [filename]"
  exit 1
fi
if [ "$1" == "all" ] && [ -n "$2" ]
then
  echo "wrong parameter, only accept all or [name] [site] [date] [filename]"
  echo "usage: $0 [all|name] [youtube|bilibili|twitch|twitcast] [folderbydate] [filename]"
  exit 1
fi
NAME="${1:-all}"
SITE="$2"
SAVEFOLDER=$(grep "Savefolder" ./config/global.config|awk -F = '{print $2}')
LOG_PREFIX=$(date +"[%Y-%m-%d %H:%M:%S]")
LOG_SUFFIX=$(date +"%Y%m%d_%H%M%S")
echo "$LOG_PREFIX ===autoclean=== check ./log/clean_$LOG_SUFFIX.log for detail"
[ "$NAME" != "all" ] && SAVEFOLDER="${SAVEFOLDER}/${NAME}"
[ -n "$SITE" ] && SAVEFOLDER="${SAVEFOLDER}/${SITE}"
[ -n "$3" ] && SAVEFOLDER="${SAVEFOLDER}/${3}"
if [ -n "$4" ]
then 
  FILENAME=$(echo "$4"|awk -F . '{print $1}')
  echo "$LOG_PREFIX below files will be deleted:" >> "./log/clean_${LOG_SUFFIX}.log"
  find $SAVEFOLDER -maxdepth 4 -name "*.*" -size 0 -type f -exec ls -l {} \; >> "./log/clean_${LOG_SUFFIX}.log" 2>&1
  find $SAVEFOLDER -maxdepth 4 -name "*.*" -size 0 -type f -delete ; >> "./log/clean_${LOG_SUFFIX}.log" 2>&1
  find $SAVEFOLDER -maxdepth 4 -name "${FILENAME}.*" -type f -exec ls -l {} \; >> "./log/clean_${LOG_SUFFIX}.log" 2>&1
  find $SAVEFOLDER -maxdepth 4 -name "${FILENAME}.*" -type f -delete ; >> "./log/clean_${LOG_SUFFIX}.log" 2>&1
  exit 0
fi
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
#check if download or upload is running
if [ -z "$STREAMLINK_PROCESS" ] && [ -z "$FFMPEG_PROCESS" ] && [ -z "$BAIDUPCS_PROCESS" ] && [ -z "$RCLONE_PROCESS" ]
then
  echo "$LOG_PREFIX below files will be deleted:" >> "./log/clean_${LOG_SUFFIX}.log"
  find $SAVEFOLDER -maxdepth 4 -name "*.*" -size 0 -type f -exec ls -l {} \; >> "./log/clean_${LOG_SUFFIX}.log" 2>&1
  find $SAVEFOLDER -maxdepth 4 -name "*.*" -size 0 -type f -delete ; >> "./log/clean_${LOG_SUFFIX}.log" 2>&1
  find $SAVEFOLDER -maxdepth 4 \( -name "*.ts" -o -name "*.mp4" -o -name "*.info.txt" -o -name "*.jpg" \) -type f -exec ls -l {} \; >> "./log/clean_${LOG_SUFFIX}.log" 2>&1
  find $SAVEFOLDER -maxdepth 4 \( -name "*.ts" -o -name "*.mp4" -o -name "*.info.txt" -o -name "*.jpg" \) -type f -delete ; >> "./log/clean_${LOG_SUFFIX}.log" 2>&1
  if [ -d ~/.cache/rclone ]; then
    find ~/.cache/rclone -maxdepth 9 -name "*.*" -type f -exec ls -l {} \; >> "./log/clean_${LOG_SUFFIX}.log" 2>&1
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

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
LOG_PREFIX=$(date +"[%Y-%m-%d-%H]")
echo "$LOG_PREFIX check ./log/clean_$LOG_PREFIX.log for detail"
#check if download or upload is running
if [ -z "$STREAMLINK_PROCESS" ] && [ -z "$FFMPEG_PROCESS" ] && [ -z "$BAIDUPCS_PROCESS" ] && [ -z "$RCLONE_PROCESS" ]
then
  echo "below files will be delete:" >> "./log/clean_${LOG_PREFIX}.log"
  find $SAVEFOLDER -maxdepth 4  -name "*.*" -size 0 -type f  -exec ls -l {} \; >> "./log/clean_${LOG_PREFIX}.log" 2>&1
  find $SAVEFOLDER -maxdepth 4  -name "*.*" -size 0 -type f -delete ; >> "./log/clean_${LOG_PREFIX}.log" 2>&1
  find $SAVEFOLDER -maxdepth 4  -name "*.ts"   -type f -exec ls -l {} \; >> "./log/clean_${LOG_PREFIX}.log" 2>&1
  find $SAVEFOLDER -maxdepth 4  -name "*.ts"   -type f -delete ; >> "./log/clean_${LOG_PREFIX}.log" 2>&1
  find $SAVEFOLDER -maxdepth 4  -name "*.info.txt"  -type f -mmin +720 -exec ls -l {} \; >> "./log/clean_${LOG_PREFIX}.log" 2>&1
  find $SAVEFOLDER -maxdepth 4  -name "*.info.txt"  -type f -mmin +720 -delete >> "./log/clean_${LOG_PREFIX}.log" 2>&1
  #find $SAVEFOLDER -maxdepth 4  -name "*.ts"   -type f -size -35k  -exec ls -l {} \; >> "./log/clean_${LOG_PREFIX}.log" 2>&1
  #find $SAVEFOLDER -maxdepth 4  -name "*.ts"   -type f -size -35k  -delete ; >> "./log/clean_${LOG_PREFIX}.log" 2>&1
  if [ -d "/root/.cache/rclone" ]; then
    find /root/.cache/rclone -maxdepth 9 -name "*.*"   -type f -exec ls -l {} \; >> "./log/clean_${LOG_PREFIX}.log" 2>&1
    rm -rf /root/.cache/rclone
  fi
elif [ -n "$STREAMLINK_PROCESS" ] || [ -n "$FFMPEG_PROCESS" ]
then
  echo "skip...stream download is in progress:" >> "./log/clean_${LOG_PREFIX}.log"
  echo "$STREAMLINK_PROCESS" >> "./log/clean_${LOG_PREFIX}.log"
  echo "$FFMPEG_PROCESS" >> "./log/clean_${LOG_PREFIX}.log"
elif [ -n "$BAIDUPCS_PROCESS" ] || [ -n "$RCLONE_PROCESS" ]
then
  echo "skip...stream upload is in progress:" >> "./log/clean_${LOG_PREFIX}.log"
  echo "$BAIDUPCS_PROCESS" >> "./log/clean_${LOG_PREFIX}.log"
  echo "$RCLONE_PROCESS" >> "./log/clean_${LOG_PREFIX}.log"
fi

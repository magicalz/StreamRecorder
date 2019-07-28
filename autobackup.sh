#!/bin/bash
#if [[ ! -n "$1" ]]; then
  #echo "usage: $0 [name|all] [youtube|bilibil|twitch|twitcast]"
  #exit 1
#fi
NAME="${1:-all}"
SITE="$2"
BACKUPMETHOD=$(grep "Backupmethod" ./config/config.global|awk -F = '{print $2}')
if [ "$NAME" != "all" ] && [ -f ./config/${NAME}.config ] && grep -q "Backupmethod" ./config/${NAME}.config
then
  BACKUPMETHOD=$(grep "Backupmethod" ./config/${NAME}.config|awk -F = '{print $2}')
fi
[[ ! -d "log" ]]&&mkdir log
LOG_PREFIX=$(date +"[%Y-%m-%d-%H]")
if [ "$NAME" == "all" ]
then
  STREAMLINK_PROCESS=$(ps -efwww|grep streamlink|grep -v 'grep')
  FFMPEG_PROCESS=$(ps -efwww|grep ffmpeg|grep -v 'grep')
else
  STREAMLINK_PROCESS=$(ps -efwww|grep streamlink|grep $NAME|grep -v 'grep')
  FFMPEG_PROCESS=$(ps -efwww|grep ffmpeg|grep $NAME|grep -v 'grep')
fi
if [ -n "$STREAMLINK_PROCESS" ] || [ -n "$FFMPEG_PROCESS" ]
then
    echo "$LOG_PREFIX skip...stream download is in progress:"
    echo "$STREAMLINK_PROCESS"
    echo "$FFMPEG_PROCESS"
    exit 1
#  fi
fi
if [ $BACKUPMETHOD == "baidu" ] || [ $BACKUPMETHOD == "all" ]
then
  echo "$LOG_PREFIX check /root/stream-recorder/log/screenlog_${LOG_PREFIX}_baidu.log for detail"
  screen -L -t ${LOG_PREFIX}"_baidu" -dmS "baidu" ./baidupanbackup.sh $NAME $SITE
fi
if [ $BACKUPMETHOD == "rclone" ] || [ $BACKUPMETHOD == "all" ]
then
  echo "$LOG_PREFIX check /root/stream-recorder/log/screenlog_${LOG_PREFIX}_rclone.log for detail"
  screen -L -t ${LOG_PREFIX}"_rclone" -dmS "rclone" ./rclonebackup.sh $NAME $SITE
fi

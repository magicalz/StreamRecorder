#!/bin/bash
#if [[ ! -n "$1" ]]; then
  #echo "usage: $0 [name|all] [youtube|bilibil|twitch|twitcast] [folderbydate] [filename]"
  #exit 1
#fi
[[ ! -d "log" ]]&&mkdir log
LOG_PREFIX=$(date +"[%Y-%m-%d %H:%M:%S]")
LOG_SUFFIX=$(date +"%Y%m%d_%H%M%S")
NAME="${1:-all}"
SITE="$2"
BACKUPMETHOD=$(grep "Backupmethod" ./config/global.config|awk -F = '{print $2}')
if [ "$NAME" != "all" ] && [ -f ./config/${NAME}.config ] && grep -q "Backupmethod" ./config/${NAME}.config
then
  BACKUPMETHOD=$(grep "Backupmethod" ./config/${NAME}.config|awk -F = '{print $2}')
fi
[ "$BACKUPMETHOD" != "baidu" ] && [ "$BACKUPMETHOD" != "rclone" ] && [ "$BACKUPMETHOD" != "both" ] && echo "$LOG_PREFIX ===autobackup=== skip...please check config file, backupmethod should be baidu|rclone|both" && exit 1
if [ "$NAME" == "all" ]
then
  STREAMLINK_PROCESS=$(ps -efwww|grep streamlink|grep -v 'grep')
  FFMPEG_PROCESS=$(ps -efwww|grep ffmpeg|grep -v 'grep')
else
  STREAMLINK_PROCESS=$(ps -efwww|grep streamlink|grep $NAME|grep -v 'grep')
  FFMPEG_PROCESS=$(ps -efwww|grep ffmpeg|grep $NAME|grep -v 'grep')
fi
if [ -z "$4" ] && [ -n "$STREAMLINK_PROCESS" ] || [ -n "$FFMPEG_PROCESS" ]
then
    echo "$LOG_PREFIX ===autobackup=== skip...stream download in progress:"
    echo "$STREAMLINK_PROCESS"
    echo "$FFMPEG_PROCESS"
    exit 1
fi
echo "$LOG_PREFIX ===autobackup=== check ./log/screen/screenlog_autobackup_${LOG_SUFFIX}.log for detail"
screen -L -t "autobackup_${LOG_SUFFIX}" -dmS "autobackup" ./backuper.sh $BACKUPMETHOD $NAME $SITE $3 $4

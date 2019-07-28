#!/bin/bash
# Bil
#$BIL $FORMAT $3 $INTERVAL $SAVEFOLDER&
FORMAT="${2:-best}"
INTERVAL="${4:-130}"
AUTOBACKUP=$(grep "Autobackup" ./config/config.global|awk -F = '{print $2}')
SITE="bilibili"
YOUTUBE=$(grep "Youtube" ./config/"$7".config|awk -F = '{print $2}')

while true; do
  # Monitor live streams of specific channel
  while true; do
    LOG_PREFIX=$(date +"[%Y-%m-%d %H:%M:%S]")
    echo "$LOG_PREFIX Try to get current live stream of $1"

    # Get the m3u8 or flv address with streamlink
    #curl -s "https://api.live.bilibili.com/room/v1/Room/get_info?room_id=$1&from=room"|grep -q '\"live_status\"\:1'&& break
    #wget -q -O-  "https://api.live.bilibili.com/room/v1/Room/get_info?room_id=$1&from=room"|grep -q '\"live_status\"\:1'&& break
    if wget -q -O- "https://api.live.bilibili.com/room/v1/Room/get_info?room_id=$1&from=room"|grep -q '\"live_status\"\:1'
    then
    echo "$LOG_PREFIX bilibili is live"
      if wget -q -O- https://www.youtube.com/channel/$YOUTUBE/live|grep -q '\\"isLive\\":true'
      then
        echo "$LOG_PREFIX skip...youtube is already streaming"
      else
        break 
      fi
    else 
      echo "$LOG_PREFIX The stream is not available now."
    fi
    echo "$LOG_PREFIX Retry after $INTERVAL seconds..."
    sleep $INTERVAL
  done
    
  # Savetitle
  TITLE=$(you-get -i https://live.bilibili.com/$1|sed -n '2p'|cut -c 22-|cut -d '.' -f 1|sed 's/[()/\\!-\$]//g')
  # Record using MPEG-2 TS format to avoid broken file caused by interruption
  FNAME="bil_$1_${TITLE}_$(date +"%Y%m%d_%H%M%S").ts"
  #FNAME="bil_$1_$(date +"%Y%m%d_%H%M%S").ts" 
  echo "$LOG_PREFIX Start recording, stream saved to $5$FNAME."
  echo "$LOG_PREFIX Use command \"tail -f ${6}${FNAME}.log\" to track recording progress."

  # Start recording
  #M3U8_URL=$(streamlink --stream-url "https://live.bilibili.com/$1" "best")
  #ffmpeg  -i "$M3U8_URL" -codec copy   -f hls -hls_time 3600 -hls_list_size 0 "$5$FNAME" > "${6}${FNAME}.log" 2>&1
  streamlink --hls-live-restart --loglevel trace -o "$5$FNAME" \
  "https://live.bilibili.com/${1}" "$FORMAT" > "${6}${FNAME}.log" 2>&1
  #STREAMSUCCESS=$?
  # Backup stream if autobackup is on
    sleep 5
    if [ "$AUTOBACKUP" == "on" ]
    then
      #if [ $STREAMSUCCESS -eq 0 ]
      if tail -n 5 "${6}${FNAME}.log"|grep -q "Stream ended"  
      then
        ./autobackup.sh $7 $SITE &
      else
        echo "stream record fail, check "${6}${FNAME}.log" for detail."
      fi
    fi
  # Exit if we just need to record current stream
  LOG_PREFIX=$(date +"[%Y-%m-%d %H:%M:%S]")
  echo "$LOG_PREFIX Live stream recording stopped."
  [[ "$3" == "once" ]] && break
done

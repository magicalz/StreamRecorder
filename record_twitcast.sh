#!/bin/bash
# TwitCasting Live Stream Recorder
if [[ ! -n "$1" ]]; then
  echo "usage: $0 twitcasting_id [loop|once] [interval] [savefolder] [logfolder] [name]"
  exit 1
fi

INTERVAL="${3:-120}"
STREAMORRECORD="${7:-record}"
RTMPURL="$8"
AUTOBACKUP=$(grep "Autobackup" ./config/config.global|awk -F = '{print $2}')
SITE="twitcast"
LIVE_URL="https://twitcasting.tv/$1"

if [[ ! -f "./livedl" ]]; then
  echo "This script depends on livedl (https://github.com/himananiito/livedl)."
  echo "Please put the binary file of livedl in the same directory first."
  exit 1
fi

while true; do
  # Monitor live streams of specific user
  while true; do
    LOG_PREFIX=$(date +"[%Y-%m-%d %H:%M:%S]")
    echo "$LOG_PREFIX Try to get current live stream of twitcasting.tv/$1"
    STREAM_API="https://twitcasting.tv/streamserver.php?target=$1&mode=client"
	#(curl -s "$STREAM_API" | grep -q '"live":true') && break
	(wget -q -O- "$STREAM_API" | grep -q '"live":true') && break
    echo "$LOG_PREFIX The stream is not available now."
    echo "$LOG_PREFIX Retry after $INTERVAL seconds..."
    sleep $INTERVAL
  done
 
  # Record using MPEG-2 TS format to avoid broken file caused by interruption
  MOVIEID=$(wget -q -O- ${LIVE_URL} | grep data-movie-id | awk -F '[=\"]+' '{print $2}')
  LIVEDL_FNAME="${1}_${MOVIEID}.ts" 
  FNAME="twitcast_$(date +"%Y%m%d_%H%M%S")_${MOVIEID}.ts"
  echo "$LOG_PREFIX Start recording, stream saved to $4$FNAME."
  echo "$LOG_PREFIX Use command \"tail -f ${5}${FNAME}.log\" to track recording progress."

  # Also record low resolution stream simultaneously as backup
  #M3U8_URL="http://twitcasting.tv/$1/metastream.m3u8?video=1"
  #ffmpeg -i "$M3U8_URL" -codec copy -f mpegts "$FNAME" > "$FNAME.log" 2>&1 &

  # Start recording

  ./livedl -tcas "$1" > "${5}${FNAME}.log" 2>&1
  STREAMSUCCESS=$? 
  #move stream file to streamrecorded folder
  sleep 5
  [ -f "./${LIVEDL_FNAME}" ] && mv ./$LIVEDL_FNAME $4$FNAME
  sleep 10
  # backup stream if autobackup is on
  if [ "$AUTOBACKUP" == "on" ]
  then
    #if tail -n 5 "${5}${FNAME}.log"|grep -q "Stream ended"
    if [ $STREAMSUCCESS -eq 0 ] 
    then
      ./autobackup.sh $6 $SITE &
    else
      echo "stream record fail, check "${5}${FNAME}.log" for detail."
    fi
  fi

  # Exit if we just need to record current stream
  LOG_PREFIX=$(date +"[%Y-%m-%d %H:%M:%S]")
  echo "$LOG_PREFIX Live stream recording stopped."
  [[ "$2" == "once" ]] && break
done

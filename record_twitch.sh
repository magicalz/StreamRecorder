#!/bin/bash
# Twitch Live Stream Recorder

if [[ ! -n "$1" ]]; then
  echo "usage: $0 twitch_id [format] [loop|once] [interval] [savefolder] [name]"
  exit 1
fi

# Record the highest quality available by default
FORMAT="${2:-best}"
INTERVAL="${4:-10}"
STREAMORRECORD="${8:-record}"
RTMPURL="$9"
AUTOBACKUP=$(grep "Autobackup" ./config/config.global|awk -F = '{print $2}')
SITE="twitch"

while true; do
  # Monitor live streams of specific channel
  while true; do
    LOG_PREFIX=$(date +"[%Y-%m-%d %H:%M:%S]")
    echo "$LOG_PREFIX Try to get current live stream of twitch.tv/$1"

    # Get the m3u8 address with streamlink
	#curl -s https://api.twitch.tv/kraken/streams/$1?client_id=key|grep -q live&& break
	wget -q -O-  https://api.twitch.tv/kraken/streams/$1?client_id=key|grep -q live&& break
    echo "$LOG_PREFIX The stream is not available now."
    echo "$LOG_PREFIX Retry after $INTERVAL seconds..."
    sleep $INTERVAL
  done
  TITLE=$(youtube-dl --get-description "https://www.twitch.tv/$1"|sed 's/[()/\\!-\$]//g')
  ID=$(youtube-dl --get-id "https://www.twitch.tv/$1"|sed 's/[()/\\!-\$]//g')

  # Record using MPEG-2 TS format to avoid broken file caused by interruption
  FNAME="twitch_${ID}_${TITLE}_$(date +"%Y%m%d_%H%M%S").ts"
  echo "$LOG_PREFIX Start recording, stream saved to $5$FNAME."
  echo "$LOG_PREFIX Use command \"tail -f ${6}${FNAME}.log\" to track recording progress."

  # Start recording
  #M3U8_URL=$(streamlink --stream-url "https://www.twitch.tv/$1" "$FORMAT")
  #ffmpeg   -i "$M3U8_URL" -codec copy   -f hls -hls_time 3600 -hls_list_size 0 "$5$FNAME" > "${6}${FNAME}.log"  2>&1
  if [ "$STREAMORRECORD" == "both" ]
  then
    streamlink --loglevel trace "https://www.twitch.tv/${1}" "1080p,720p,best" -o - | ffmpeg -re -i pipe:0 \
    -codec copy -f mpegts "$5$FNAME" \
    -vcodec copy -acodec aac -strict -2 -f flv "${RTMPURL}" \
    > "${6}${FNAME}.log" 2>&1
  elif [ "$STREAMORRECORD" == "record" ]
  then
    streamlink --hls-live-restart --loglevel trace -o "$5$FNAME" \
    "https://www.twitch.tv/${1}" "1080p,720p,best" > "${6}${FNAME}.log" 2>&1
  elif [ "$STREAMORRECORD" == "stream" ]
  then
    streamlink --loglevel trace "https://www.twitch.tv/${1}" "1080p,720p,best" -o - | ffmpeg -re -i pipe:0 \
    -vcodec copy -acodec aac -strict -2 -f flv "${RTMPURL}" \
    > "${6}${FNAME}.log" 2>&1
  else
    echo "skip...please check StreamOrRecord parameter in config file, should be record|stream|both"
  fi 
  #STREAMSUCCESS=$?
  # backup stream if autobackup is on
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

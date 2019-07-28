#!/bin/bash
# YouTube Live Stream Recorder

if [[ ! -n "$1" ]]; then
  echo "usage: $0 live_url [format] [loop|once] [interval] [savefolder] [logfolder] [name] [STREAMORRECORD] [RTMPURL]"
  exit 1
fi


# Record the highest quality available by default
FORMAT="${2:-best}"
INTERVAL="${4:-100}"
NAME="$7"
STREAMORRECORD="${8:-record}"
RTMPURL="$9"
AUTOBACKUP=$(grep "Autobackup" ./config/config.global|awk -F = '{print $2}')
SITE="youtube"

# Construct full URL if only channel id given
LIVE_URL=$1
[[ "$1" == "http"* ]] || LIVE_URL="https://www.youtube.com/channel/$1/live"

while true; do
  # Monitor live streams of specific channel
  while true; do
    LOG_PREFIX=$(date +"[%Y-%m-%d %H:%M:%S]")
    echo "$LOG_PREFIX Checking \"$LIVE_URL\"..."

    # Try to get video id and title of current live stream.
    # Add parameters about playlist to avoid downloading
    # the full video playlist uploaded by channel accidently.

  #curl -s  https://www.youtube.com/channel/$1|grep -q "ライブ配信中" && break
  #curl -s -N https://www.youtube.com/channel/$1/live|grep -q '\\"isLive\\":true' && break
  wget -q -O- $LIVE_URL|grep -q '\\"isLive\\":true' && break

    echo "$LOG_PREFIX The stream is not available now."
    echo "$LOG_PREFIX Retry after $INTERVAL seconds..."
    sleep $INTERVAL
  done
    METADATA=$(youtube-dl --get-id --get-title --get-description \
      --no-check-certificate --no-playlist --playlist-items 1 \
      "${LIVE_URL}" 2>/dev/null)
	#Savetitle
  #Title=$(echo "$METADATA" | sed -n '1p'|sed 's#[()/\\!-\$]##g')

  # Extract video id of live stream
  ID=$(echo "$METADATA" | sed -n '2p')

  # Record using MPEG-2 TS format to avoid broken file caused by interruption
  #FNAME="youtube_${Title}_$(date +"%Y%m%d_%H%M%S")_${ID}.ts"
  FNAME="youtube_$(date +"%Y%m%d_%H%M%S")_${ID}.ts" 
  # Also save the metadate to file
  if [ -n "$METADATA" ]
  then 
    echo "$METADATA" > "${5}metadata/${FNAME}.info.txt"

  # Print logs
    echo "$LOG_PREFIX Start recording, metadata saved to ${5}metadata/${FNAME}.info.txt."
    echo "$LOG_PREFIX Use command \"tail -f ${6}${FNAME}.log\" to track recording progress."

  # Start recording
  # ffmpeg -i "$M3U8_URL" -codec copy -f mpegts "savevideo/$FNAME" > "savevideo/$FNAME.log" 2>&1

  # Use streamlink to record for HLS seeking support
    #M3U8_URL=$(streamlink --stream-url "https://www.youtube.com/watch?v=${ID}" "best")
    #ffmpeg   -i "$M3U8_URL" -codec copy   -f hls -hls_time 3600 -hls_list_size 0 "$5$FNAME" > "${6}${FNAME}.log" 2>&1    
    if [ "$STREAMORRECORD" == "both" ]
    then
      streamlink --loglevel trace "https://www.youtube.com/watch?v=${ID}" "1080p,720p,best" -o - | ffmpeg -re -i pipe:0 \
      -codec copy -f mpegts "$5$FNAME" \ 
      -vcodec copy -acodec aac -strict -2 -f flv "${RTMPURL}" \
      > "${6}${FNAME}.log" 2>&1
    elif [ "$STREAMORRECORD" == "record" ]
    then
      streamlink --hls-live-restart --loglevel trace -o "$5$FNAME" \
      "https://www.youtube.com/watch?v=${ID}" "1080p,720p,best" > "${6}${FNAME}.log" 2>&1
    elif [ "$STREAMORRECORD" == "stream" ]
    then
      streamlink --loglevel trace "https://www.youtube.com/watch?v=${ID}" "1080p,720p,best" -o - | ffmpeg -re -i pipe:0 \
      -vcodec copy -acodec aac -strict -2 -f flv "${RTMPURL}" \
      > "${6}${FNAME}.log" 2>&1 
    else
      echo "skip...please check StreamOrRecord parameter in config file, should be record|stream|both" 
    fi
  # backup stream if autobackup is on 
    sleep 5 
    if [ "$AUTOBACKUP" == "on" ] 
    then
      if tail -n 5 "${6}${FNAME}.log"|grep -q "Stream ended" 
      then
        ./autobackup.sh $NAME $SITE &
      else
        echo "$LOG_PREFIX stream record fail, check "${6}${FNAME}.log" for detail." 
      fi
    fi  
  else
    echo "youtube metadata is empty!"
  fi

  # Exit if we just need to record current stream
  LOG_PREFIX=$(date +"[%Y-%m-%d %H:%M:%S]")
  echo "$LOG_PREFIX Live stream recording stopped."
  [[ "$3" == "once" ]] && break
done

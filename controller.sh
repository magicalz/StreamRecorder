#!/bin/bash

if [[ ! -n "$1" ]]
then
  echo "usage: $0 [name] [format]"
  exit 1
fi

if [ ! -f ./config/${1}.config ]
then
  echo "skip...$1 config file does not exist"
  exit 1
fi

FORMAT="${2:-best}"
INTERVAL="${4:-15}"
SAVEFOLDERGLOBAL=$(grep "Savefolder" ./config/config.global|awk -F = '{print $2}')
LOGFOLDERGLOBAL=$(grep "Logfolder" ./config/config.global|awk -F = '{print $2}')
SAVEFOLDER=$(grep "Savefolder" ./config/"$1".config|cut -c 12-)
LOGFOLDER=$(grep "Logfolder" ./config/"$1".config|cut -c 11-)
INTERVAL=$(grep "Checktime" ./config/"$1".config|cut -c 11-)
LOOP=$(grep "LoopOrOnce" ./config/"$1".config|cut -c 12-)
YOUTUBE=$(grep "Youtube" ./config/"$1".config|awk -F = '{print $2}')
BILIBILI=$(grep "Bilibili" ./config/"$1".config|awk -F = '{print $2}')
TWITCH=$(grep "Twitch" ./config/"$1".config|awk -F = '{print $2}')
TWITCAST=$(grep "Twitcast" ./config/"$1".config|awk -F = '{print $2}')
#OPENREC=$(grep "openrec" ./config/"$1".config|grep -v https://www.openrec.tv/user/|cut -c 29-)
STREAMORRECORD=$(grep "StreamOrRecord" ./config/config.global|awk -F = '{print $2}')
if grep -q "StreamOrRecord" ./config/${1}.config
then
  STREAMORRECORD=$(grep "StreamOrRecord" ./config/${1}.config|awk -F = '{print $2}')
fi
RTMPURL=$(grep "Rtmpurl" ./config/config.global|awk -F = '{print $2}')
if grep -q "Rtmpurl" ./config/${1}.config
then
  RTMPURL=$(grep "Rtmpurl" ./config/${1}.config|awk -F = '{print $2}')
fi

([ "$STREAMORRECORD" == "both" ] || [ "$STREAMORRECORD" == "stream" ]) && [ -z "$RTMPURL" ] && echo "skip...Rtmpurl is empty, please check StreamOrRecord and Rtmpurl parameters in config file" && exit 1

[[ ! -d "${SAVEFOLDERGLOBAL}" ]]&&mkdir ${SAVEFOLDERGLOBAL}
[[ ! -d "${LOGFOLDERGLOBAL}" ]]&&mkdir ${LOGFOLDERGLOBAL}
[[ ! -d "${SAVEFOLDER}" ]]&&mkdir ${SAVEFOLDER}
[[ ! -d "${LOGFOLDER}" ]]&&mkdir ${LOGFOLDER}

#youtube

if [[ -n "$YOUTUBE" ]]; then  
[[ ! -d "${SAVEFOLDER}youtube" ]]&&mkdir ${SAVEFOLDER}youtube
[[ ! -d "${SAVEFOLDER}youtube/metadata" ]]&&mkdir ${SAVEFOLDER}youtube/metadata
[[ ! -d "${LOGFOLDER}youtube" ]]&&mkdir ${LOGFOLDER}youtube
sleep 5
./record_youtube.sh $YOUTUBE $FORMAT $LOOP $INTERVAL ${SAVEFOLDER}youtube/ ${LOGFOLDER}youtube/ $1 $STREAMORRECORD $RTMPURL &
sleep 10
fi

#bil    
if [[ -n "$BILIBILI" ]]; then
[[ ! -d "${SAVEFOLDER}bilibili" ]]&&mkdir ${SAVEFOLDER}bilibili
[[ ! -d "${SAVEFOLDER}bilibili/metadata" ]]&&mkdir ${SAVEFOLDER}bilibili/metadata
[[ ! -d "${LOGFOLDER}bilibili" ]]&&mkdir ${LOGFOLDER}bilibili
sleep 5
./record_bilibili.sh $BILIBILI $FORMAT $LOOP $INTERVAL ${SAVEFOLDER}bilibili/ ${LOGFOLDER}bilibili/ $1 &
sleep 10
fi

#twitch twitch_id [format] [loop|once] [interval] [savefolder]
if [[ -n "$TWITCH" ]]; then
[[ ! -d "${SAVEFOLDER}twitch" ]]&&mkdir ${SAVEFOLDER}twitch
[[ ! -d "${SAVEFOLDER}twitch/metadata" ]]&&mkdir ${SAVEFOLDER}twitch/metadata
[[ ! -d "${LOGFOLDER}twitch" ]]&&mkdir ${LOGFOLDER}twitch
sleep 5
./record_twitch.sh $TWITCH $FORMAT $LOOP $INTERVAL ${SAVEFOLDER}twitch/ ${LOGFOLDER}twitch/ $1 $STREAMORRECORD $RTMPURL &
sleep 10
fi
#TWITCAST
if [[ -n "$TWITCAST" ]]; then
[[ ! -d "${SAVEFOLDER}twitcast" ]]&&mkdir ${SAVEFOLDER}twitcast
[[ ! -d "${SAVEFOLDER}twitcast/metadata" ]]&&mkdir ${SAVEFOLDER}twitcast/metadata
[[ ! -d "${LOGFOLDER}twitcast" ]]&&mkdir ${LOGFOLDER}twitcast
#sleep 5
#[[ ! -f "${SAVEFOLDER}twitcast/livedl" ]]&&ln ./livedl ${SAVEFOLDER}twitcast/
sleep 5
./record_twitcast.sh $TWITCAST $LOOP $INTERVAL ${SAVEFOLDER}twitcast/ ${LOGFOLDER}twitcast/ $1 $STREAMORRECORD $RTMPURL &
sleep 10
fi
#OPENREC
#./record_openrec.sh $OPENRCE $FORAMT $LOOP $INTERVAL ${SAVEFOLDER}&

wait

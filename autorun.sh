#!/bin/bash
source /etc/profile
cd /root/stream-recorder
LOG_PREFIX=$(date +"[%Y-%m-%d-%H]")
for ((NUM=$(ls ./config|grep -c .config); NUM>0; --NUM))
do
NAME=$(ls ./config|grep .config|sed 's/.config//g'|sed -n "$NUM"p)
sleep 1
if [ -z "$(screen -ls|grep $NAME)" ]
then
screen -L -t ${LOG_PREFIX}_${NAME} -dmS $NAME ./controller.sh $NAME
#SCREENPID=$!
#echo "$NAME.$SCREENPID" >> "./screenpid.txt"
sleep 1
echo "running new screen for $NAME"
echo "check /root/stream-recorder/log/screenlog_${LOG_PREFIX}_${NAME}.log for detail"
else
echo "skip...screen for $NAME already running"
fi
done

#!/bin/bash
source /etc/profile
cd `dirname $0`
LOG_PREFIX=$(date +"[%Y-%m-%d %H:%M:%S]")
LOG_SUFFIX=$(date +"%Y%m%d_%H%M%S")
for ((NUM=$(ls ./config|grep -v global|grep -c .config); NUM>0; --NUM))
do
NAME=$(ls ./config|grep .config|grep -v global|sed 's/.config//g'|sed -n "$NUM"p)
if [ -z "$(screen -ls|grep $NAME)" ]
then
sleep 1
screen -L -t ${NAME}_${LOG_SUFFIX} -dmS $NAME ./controller.sh $NAME
sleep 1
echo "$LOG_PREFIX running new screen for $NAME"
echo "$LOG_PREFIX check ./log/screen/screenlog_${NAME}_${LOG_SUFFIX}.log for detail"
else
echo "$LOG_PREFIX skip...screen for $NAME already running"
fi
done

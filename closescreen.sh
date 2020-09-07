#!/bin/bash
LOG_PREFIX=$(date +"[%Y-%m-%d %H:%M:%S]")
LOG_SUFFIX=$(date +"%Y%m%d_%H%M%S")
if [ "$1" == "all" ]
then
  screen -ls|awk '{line[NR]=$1}END{for(i=2;i<=NR-1;i++)print "screen -X -S "line[i]" quit"}'|sh
  echo "$LOG_PREFIX ===closescreen=== all screens have been closed"
  exit 0
fi
screen -ls
echo "Please input the name of screen you want to close, input all to close all screens, input exit to exit:"
read NAME
[ "$NAME" == "exit" ]&&exit 0
if [ "$NAME" == "all" ]
then
#LINECOUNT=$(screen -ls|wc -l)
#screen -ls|awk -v line=$LINECOUNT -F '[ .]+' 'NR>=2&&NR<=line-2{print $1}'|awk '{print "screen -X -S "$0" quit"}'|sh
screen -ls|awk '{line[NR]=$1}END{for(i=2;i<=NR-1;i++)print "screen -X -S "line[i]" quit"}'|sh
echo "$LOG_PREFIX ===closescreen=== all screens have been closed"
else
echo "$LOG_PREFIX ===closescreen=== below screen will be closed:"
screen -ls|grep $NAME
screen -ls|grep $NAME|awk -F '[ .]+' '{print $1}'|awk '{print "screen -X -S "$0" quit"}'|sh
fi

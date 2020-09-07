#!/bin/bash
cd `dirname $0`
if [[ ! -n "$1" ]]; then
  echo "usage: $0 [start|restart|stop|cleanfile|cleanlog|backup]"
  exit 1
fi
if [ "$1" == "start" ]
then
  ./autorun.sh
elif [ "$1" == "stop" ]
then
  ./closescreen.sh
elif [ "$1" == "restart" ]
then
  ./closescreen.sh all
  ./autorun.sh
elif [ "$1" == "cleanfile" ]
then
  ./autoclean.sh all
elif [ "$1" == "cleanlog" ]
then
  ./cleanlog.sh
elif [ "$1" == "backup" ]
then
  ./autobackup.sh all
else
  echo "wrong parameter, please input parameter as bellow:"
  echo "usage: $0 [start|restart|stop|cleanfile|cleanlog|backup]"
fi

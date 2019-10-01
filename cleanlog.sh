#!/bin/bash

SAVEFOLDERGLOBAL=$(grep "Savefolder" ./config/global.config|awk -F = '{print $2}')
LOGFOLDERGLOBAL=$(grep "Logfolder" ./config/global.config|awk -F = '{print $2}')
SCREENLOGFOLDER=$(grep "Screenlogfolder" ./config/global.config|awk -F = '{print $2}')
LOG_SUFFIX=$(date +"%Y%m%d_%H%M%S")

find ./$SAVEFOLDERGLOBAL/  -maxdepth 4  \( -name "*.ts" -o -name "*.mp4" -o -name "*.info.txt" -o -name "*.jpg" \) -type f -mmin +720 -exec ls -l {} \; > "./log/cleanlog_$LOG_SUFFIX.log" 2>&1
find ./$SAVEFOLDERGLOBAL/  -maxdepth 4  \( -name "*.ts" -o -name "*.mp4" -o -name "*.info.txt" -o -name "*.jpg" \) -type f -mmin +720 -delete >> "./log/cleanlog_$LOG_SUFFIX.log" 2>&1
find ./$SAVEFOLDERGLOBAL/  -maxdepth 4  -name "*.ts.*"  -type f -mmin +720 -exec ls -l {} \; >> "./log/cleanlog_$LOG_SUFFIX.log" 2>&1
find ./$SAVEFOLDERGLOBAL/  -maxdepth 4  -name "*.ts.*"  -type f -mmin +720 -delete >> "./log/cleanlog_$LOG_SUFFIX.log" 2>&1
find ./$SAVEFOLDERGLOBAL/  -mindepth 3 -maxdepth 3  -name "[0-9]*"  -type d -empty -mmin +720 >> "./log/cleanlog_$LOG_SUFFIX.log" 2>&1
find ./$SAVEFOLDERGLOBAL/  -mindepth 3 -maxdepth 3  -name "[0-9]*"  -type d -empty -mmin +720 -exec rm -rf {} \; >> "./log/cleanlog_$LOG_SUFFIX.log" 2>&1
find ./$LOGFOLDERGLOBAL/ -maxdepth 3  -name "*.log"  -type f -mmin +1440 -exec ls -l {} \; >> "./log/cleanlog_$LOG_SUFFIX.log" 2>&1
find ./$LOGFOLDERGLOBAL/ -maxdepth 3  -name "*.log"  -type f -mmin +1440 -delete >> "./log/cleanlog_$LOG_SUFFIX.log" 2>&1
find $SCREENLOGFOLDER -name "*.log"  -type f -mmin +1440 -exec ls -l {} \; >> "./log/cleanlog_$LOG_SUFFIX.log" 2>&1
find $SCREENLOGFOLDER -name "*.log"  -type f -mmin +1440 -delete >> "./log/cleanlog_$LOG_SUFFIX.log" 2>&1


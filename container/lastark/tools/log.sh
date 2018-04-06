#!/bin/bash
source "$HOME/lastark/lib/config.shlib";

DESC=$1
LOG=$2

LOG_DIR="/var/log/lastark"
LOG_FILE="LOG"

mkdir -p "$LOG_DIR"

DATE=`date +%Y-%m-%d`
TIME=`date +%T`
#YEAR=`date +%Y`
#MONTH=`date +%m`
#DAY=`date +%d`

echo "[$DESC][$DATE $TIME] - $LOG" >> "$LOG_DIR/$LOG_FILE"

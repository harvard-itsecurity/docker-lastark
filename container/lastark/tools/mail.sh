#!/bin/bash
source "$HOME/lastark/lib/config.shlib";

NOTIFICATION_FROM_DOMAIN=$(config_get notification_from_email)

TO=$1
SUBJ=$2
MSG=$3

#DATE=`date +%Y-%m-%d`
#YEAR=`date +%Y`
#MONTH=`date +%m`
#DAY=`date +%d`

mail -r "Last Pass <$NOTIFICATION_FROM_DOMAIN>" -s "$SUBJ" "$TO" <<< "$MSG"
"$HOME/lastark/tools/log.sh" "MAIL SENT" "$TO -> $SUBJ"

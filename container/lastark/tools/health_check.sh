#!/bin/bash
source "$HOME/lastark/lib/config.shlib";

NOTIFICATION_TO_EMAIL=$(config_get notification_to_email)

LPASS="/usr/bin/lpass";
R=$($LPASS ls | grep 'STUB-DO-NOT-DELETE');

if [[ -z $R ]]; then
    sleep 30
    R=$($LPASS ls | grep 'STUB-DO-NOT-DELETE');
    if [[ -z $R ]]; then
        sleep 60
        R=$($LPASS ls | grep 'STUB-DO-NOT-DELETE');
        if [[ -z $R ]]; then
            "$HOME/lastark/tools/mail.sh" $NOTIFICATION_TO_EMAIL "[EMERGENCY]: LastArk Health Check - LastPass Login Token Missing!" "It looks like the LPASS CLI token is missing!"
            exit 1;
        fi
    fi
fi

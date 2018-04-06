#!/bin/bash
source "$HOME/lastark/lib/config.shlib";

NOTIFICATION_TO_EMAIL=$(config_get notification_to_email)
ORGANIZATION_TYPE=$(config_get organization_type)

USER=$1

LPASS="/usr/bin/lpass";
#R=$($LPASS ls | grep 'STUB-DO-NOT-DELETE');

#if [[ -z $R ]]; then
#    echo "!!! PLEASE LOGIN WITH LPASS CLI! !!!"; echo;
#    "$HOME/lastark/tools/log.sh" "*CRITICAL ERROR* - LPASS CLI TOKEN MISSING" "It looks like the LPASS CLI token is missing!"
#    "$HOME/lastark/tools/mail.sh" $NOTIFICATION_TO_EMAIL "[EMERGENCY]: LastArk - LastPass Login Token Missing!" "It looks like the LPASS CLI token is missing!"
#    rm -Rf /var/lock/lastark
#    exit 1;
#fi

echo "Generate Random Password for: $USER";
RANDOM_PASS=$($LPASS generate --sync=now --username="$USER" $ORGANIZATION_TYPE-AD-$USER 20);
#RANDOM_PASS=$($LPASS generate --sync=auto --username="$USER" $ORGANIZATION_TYPE-AD-$USER 20);

# > /dev/null 2>&1
# guarantee sync - needed
#echo "Force Sync";
#$LPASS sync

echo "Moving to User Share: Shared-$ORGANIZATION_TYPE-AD-$USER";
$LPASS mv --sync=now $ORGANIZATION_TYPE-AD-$USER Shared-$ORGANIZATION_TYPE-AD-$USER
# guarantee sync - needed
#echo "Force Sync";
#$LPASS sync
echo "Rotating AD Password for: $USER";
$HOME/lastark/tools/change-pass.sh "$USER" "$RANDOM_PASS"
$HOME/lastark/tools/log.sh "LP PASS UPDATE" "$USER"
sleep 6

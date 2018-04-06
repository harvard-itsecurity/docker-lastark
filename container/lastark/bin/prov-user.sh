#!/bin/bash
source "$HOME/lastark/lib/config.shlib";

NOTIFICATION_TO_EMAIL=$(config_get notification_to_email)
LASTPASS_ACCOUNT_ADMIN=$(config_get lastpass_account_admin)
ORGANIZATION_TYPE=$(config_get organization_type)


USER=$1

LPASS="/usr/bin/lpass";
R=$($LPASS ls | grep 'STUB-DO-NOT-DELETE');
if [[ -z $R ]]; then
    echo "!!! PLEASE LOGIN WITH LPASS CLI! !!!"; echo;
    "$HOME/lastark/tools/log.sh" "*CRITICAL ERROR* - LPASS CLI TOKEN MISSING" "It looks like the LPASS CLI token is missing!"
    "$HOME/lastark/tools/mail.sh" $NOTIFICATION_TO_EMAIL "[EMERGENCY]: LastArk - LastPass Login Token Missing" "It looks like the LPASS CLI token is missing!"
    rm -Rf /var/lock/lastark
    exit 1;
fi

echo "Starting to Provision: $USER"

EMAIL=$($HOME/lastark/tools/find-email.sh "$USER")
if [[ -z $EMAIL ]]; then
    "$HOME/lastark/tools/mail.sh" $NOTIFICATION_TO_EMAIL "[INFO]: LastArk - AD Email Missing for user [$USER]!" "It looks $USER is missing an email address. This means we cannot enroll them into LastArk for AD Password Management!"
    echo $USER >> $HOME/lastark/users/users.failed.provision
    exit;
fi
echo "Email Found: $EMAIL"

echo "Creating Share: $ORGANIZATION_TYPE-AD-$USER";
$LPASS share create $ORGANIZATION_TYPE-AD-$USER
# guarantee sync - needed - should wait ~3-6 seconds after that before "guaranteed to be there"
$LPASS sync

sleep 5

R=$($LPASS share userls "Shared-$ORGANIZATION_TYPE-AD-$USER" | grep 'User                                         RO  Admin   Hide OutEnt Accept');
if [[ -z $R ]]; then
    echo "ERROR>> Creating Share Failed: $ORGANIZATION_TYPE-AD-$USER"
    "$HOME/lastark/tools/log.sh" "*ERROR* - Create Share for User" "$USER"
    "$HOME/lastark/tools/mail.sh" "[EMERGENCY]: LastArk - Creating LastPass Share for User [$USER] Failed!" "It looks we could NOT create $ORGANIZATION_TYPE-AD-$USER. It could be that the sync did not properly propagate or that not enough time has passed. Double check for this manually, and if it exists, please remove it and disregard this message. If this happens more than a couple of times, please report it as an issue via GitHub!"
    echo $USER >> $HOME/lastark/users/users.failed.provision
    exit;
else
    echo $USER >> $HOME/lastark/users/users.txt
fi

echo "Add user [via email: $EMAIL] to: $ORGANIZATION_TYPE-AD-$USER";
$LPASS share useradd --read-only=true --hidden=false Shared-$ORGANIZATION_TYPE-AD-$USER $LASTPASS_ACCOUNT_ADMIN
$LPASS share useradd --read-only=true --hidden=false Shared-$ORGANIZATION_TYPE-AD-$USER "$EMAIL"
# guarantee sync - needed
$LPASS sync

# Let the user know they have been enrolled!
"$HOME/lastark/tools/log.sh" "Successfully Enrolled User" "$USER"

"$HOME/lastark/tools/mail.sh" "$EMAIL" "[ACTION REQUIRED][$USER] LastArk AD Account Enrollement" "Your Active Directory account [$USER] has been enrolled under LastArk's Credential Rotation Service. LastArk generates a random password, updates your LastPass Enterprise account [$EMAIL], and syncs your AD account automatically. You will receive an email titled \"LastPass Notification: You've been added to a Shared Folder\". Please open it and click the \"accept this item\". After that, you can use your LastPass Enterprise account to view the password whenever you need access to your AD account. Thank you!"

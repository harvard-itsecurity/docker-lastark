#!/bin/bash
source "$HOME/lastark/lib/config.shlib";

NOTIFICATION_TO_EMAIL=$(config_get notification_to_email)

if mkdir /var/lock/lastark; then
    #echo "Locking succeeded" >&2

    ###################################################
    # Go through provision users - only if it exists! #
    ###################################################
    if [ -e "$HOME/lastark/users/users.provision" ]
    then
        while read PROVUSERNAME
        do
            $HOME/lastark/bin/prov-user.sh "$PROVUSERNAME"
        done < $HOME/lastark/users/users.provision

        mv -f $HOME/lastark/users/users.provision $HOME/lastark/users/users.last-provision
    fi


    ##########################################
    # Go through users - only if they exist! #
    ##########################################
    if [ -e "$HOME/lastark/users/users.txt" ]
    then
        cat $HOME/lastark/users/users.txt | sort | uniq > $HOME/lastark/users/users.running

        while read USERNAME
        do
            $HOME/lastark/bin/lp-user.sh "$USERNAME"
        done < $HOME/lastark/users/users.running

        rm -f $HOME/lastark/users/users.running
    fi


    ###########
    # Cleanup #
    ###########
    rm -Rf /var/lock/lastark
else
    echo "Lock failed - exit" >&2
    LAST_LOCK=`ls -alh /var/lock/lastpass`;
    "$HOME/lastark/tools/mail.sh" $NOTIFICATION_TO_EMAIL "[EMERGENCY]: LastArk - Lock Failed" "Lock Failed: /var/lock/lastark -- did something crash? Last Lock: $LAST_LOCK"
    "$HOME/lastark/tools/log.sh" "*EMERGENCY* - Lock Failed" "Lock Failed: /var/lock/lastark -- did something crash? Last Lock: $LAST_LOCK"

    rm -Rf /var/lock/lastark
    exit 1
fi

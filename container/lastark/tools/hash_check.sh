#!/bin/bash
source "$HOME/lastark/lib/config.shlib";

NOTIFICATION_TO_EMAIL=$(config_get notification_to_email)

RUN_CONFIG_HASH=$(sha1sum "${HOME}/lastark/config/lastark.cfg" | cut -d ' ' -f 1);

if [[ "${CONFIG_HASH}" ]] && [[ "$CONFIG_HASH" != "$RUN_CONFIG_HASH" ]]; then
        "$HOME/lastark/tools/log.sh" "*SECURITY*" "Running config file hash ${RUN_CONFIG_HASH} does NOT match Expected config file hash: ${CONFIG_HASH}"
        "$HOME/lastark/tools/mail.sh" $NOTIFICATION_TO_EMAIL "[SECURITY]: LastArk - Config File Hash Change" "Running config file hash ${RUN_CONFIG_HASH} does NOT match Expected config file hash: ${CONFIG_HASH}"
fi

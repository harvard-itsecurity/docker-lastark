#!/bin/bash
source "$HOME/lastark/lib/config.shlib";
USER=$1

AD_LDAP_URI=$(config_get ad_ldap_uri)
AD_LDAP_SEARCHBASE=$(config_get ad_ldap_searchbase)
AD_LDAP_BINDDN=$(config_get ad_ldap_binddn)
AD_LDAP_BINDPASSWD=$(config_get ad_ldap_bindpasswd)

ldapsearch -l 5 -o ldif-wrap=no -E pr=10000/noprompt -z 0 -d 256 -H $AD_LDAP_URI -b "$AD_LDAP_SEARCHBASE" -D "$AD_LDAP_BINDDN" -x -w "$AD_LDAP_BINDPASSWD" "CN=$USER" 'dn' | grep 'dn: ' | sed 's/dn: //g'

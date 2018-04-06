#/bin/bash
source "$HOME/lastark/lib/config.shlib";

# Now change "home" to be relative to where this script lives!
USER=$1
PASS=$2

CN=$("$HOME/lastark/tools/find-full-dn.sh" "$USER")

AD_LDAP_URI=$(config_get ad_ldap_uri)
AD_LDAP_BINDDN=$(config_get ad_ldap_binddn)
AD_LDAP_BINDPASSWD=$(config_get ad_ldap_bindpasswd)

R=$(ldapmodify -d 256 -H $AD_LDAP_URI -D "$AD_LDAP_BINDDN" -x -w "$AD_LDAP_BINDPASSWD" 2>&1 << EOF
dn: $CN
changetype: modify
replace: userPassword
userPassword: "$PASS"
EOF
)

echo $R | grep 'Insufficient access' > /dev/null

if [ $? == 0 ]; then
	"$HOME/lastark/tools/log.sh" "*ERROR* - AD PASSWORD RESET" "$USER"
	echo -n "*ERROR* - AD PASSWORD RESET - $USER"
else
	"$HOME/lastark/tools/log.sh" "AD PASSWORD RESET" "$USER"
fi

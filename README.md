![LastArk](https://preview.ibb.co/gZew4x/lastark.png)
### Version: 1.0.0

https://github.com/harvard-itsecurity/docker-lastark

# What is LastArk?

LastArk is a replacement in functionality for CyberArk's EPV (Enterprise Password Vault) - specifically, the Privileged Identity Management (PIM) component.

In plain words: this is a better (much better!) PIM which "takes over" AD/LDAP accounts, generates long random passwords, syncs those passwords to the AD/LDAP accounts, rotates these passwords at a custom specified time interval, and then allows the user to retrieve those passwords when they need them. LastArk also adds an additional benefit of pushing the rotating password object (in real time) to each user's LastPass Enterprise account.

This allows the user to use LastPass Enterprise as a password vault, and with the addition of LastArk, as a PIM, where each user can instantly retrieve their latest active privileged account password.

# What do I need to use LastArk?

* You need a docker host which has access to the internet (direct, or via proxy)

* You need a LastPass Enterprise Account.
This is your "backend" vault, and it's what we use to bridge to the
user interface -- via LastPass.com and the LastPass Browser Extensions

* You need an AD (or LDAP) service (admin privileged/binddn) account which can modify the passwords for the users you want to manage.

* You need a SMTP (mail) relay that you can forward emails through

# How do I (quickly, in 4 steps) get started?

## 1.) Create your directory structure:
Assuming ```/docker``` is your "docker data" directory, please create these realtive folders:

a.) Config: ```/docker/config/lastark.cfg```
(see "Create a Config file" for the requried format)

b.) Users: ```/docker/users```
Users directory -- see bellow for specifics in "Volumes you can override"

c.) Logs: ```/docker/logs```
Learn more in the "Volumes you can override" section bellow.

## 2.) Create a Config file:
In your ```/docker/configs``` create a config file named: ```lastark.cfg```:

(note: format is ```key```=```value``` - please change the example values)

```
organization_type=UNIVERSITY
lastark_fqdn=lastark.fqdn.tld
password_rotation_time=15
lastpass_account_admin=lastpass-enterprise-login@fqdn.tld
lastpass_account_pass=LastPassEnterprisePassword
notification_to_email=alerts@fqdn.tld
notification_from_email=no-reply@fqdn.tld
mail_server_relay_host=mailhub.fqdn.tld
mail_server_relay_port=25
mail_server_from_domain=fqdn.tld
ad_ldap_uri=ldap://ad.fqdn.tld/
ad_ldap_searchbase=DC=oragnization,DC=fqdn,DC=tld
ad_ldap_binddn=CN=ABCD,OU=Service Accounts,OU=People,DC=oragnization,DC=fqdn,DC=tld
ad_ldap_bindpasswd=BindDNPassword
```

## 3.) Run the container:

### a.) Bootstrap your LastPass Enterprise Account - ONE TIME ONLY!

This needs to be done ONLY once -- the first time you use LastArk.
Don't run this more than one. In fact - after it runs, the container
deletes the /bootstrap script.

Bootstrap LastPass Enterprise for LastArk:
```
docker run -it --rm \
    -v /docker/lastark/config/lastark.cfg:/root/lastark/config/lastark.cfg:ro \
    -v /docker/lastark/logs:/var/log/lastark \
    harvarditsecurity/lastark \
    /bootstrap
```

### b.) Run the LastArk service:
```
docker run -it -d --restart=always \
    -p 8080:8080 \
    -v /docker/lastark/users:/root/lastark/users \
    -v /docker/lastark/config/lastark.cfg:/root/lastark/config/lastark.cfg:ro \
    -v /docker/lastark/logs:/var/log/lastark
    harvarditsecurity/lastark
```

## 4.) You are done - now add some users

Now that your LastArk service is running, add some users.

There are two ways to do this:

Either by creating a ```users.provision``` file with _one_ AD/LDAP
user per line, and then moving the file to ```/docker/users```, at
which point it will be picked up by the service on the set
```password_rotation_time``` interval.

or

By using the REST API:

```
curl -is http://docker-host:8080/provision/$username -H 'accept: text/plain'
```
Which will add the user to the ```/docker/users/users.provision```
file.

# Volumes you can override:
1.) Configs: ```/root/lastark/config/lastark.cfg```

2.) Users: ```/root/lastark/users```
Users directory, which takes/creates these files:
* users.provision = users to be auto provisioned under LastArk on the
next scheduled run (created by admin or API)

* users.last-provision = users last provisioned successfully under
LastArk

* users.failed.provision = last users _attempted_ (however, failed) to
be provisioned

* users.txt = all users under LastArk control - auto password
management/rotation

3.) Logs: ```/var/log/lastark```
Logs (by default: "LOG" file) which contains everything from informational to error to critical notices about LastArk operations

# Config File Details

Here is an explanation of each line in the config file:

```
organization_type=
lastark_fqdn=
password_rotation_time=
lastpass_account_admin=
lastpass_account_pass=
notification_to_email=
notification_from_email=
mail_server_relay_host=
mail_server_relay_port=
mail_server_from_domain=
ad_ldap_uri=ldap://REPLACE-URI-HERE/
ad_ldap_searchbase=
ad_ldap_binddn=
ad_ldap_bindpasswd=
```

* **organization_type** - This is a bit arbitrary, but it was designed as a "prefix" to the Shares created in LastPass Enterprise. In an University setting, it makes sense to set this to "UNIVERSITY"
* **lastark_fqdn** - FQDN of docker container - used for valid email relaying in one place * **password_rotation_time** - minutes between password rotations and new-user provisioning.
* **lastpass_account_admin** - LastPass Enterprise account (email) login
* **lastpass_account_pass** - LastPass Enterprise account password
* **notification_to_email** - email address used for admin/system LastArk alerts/notifications. One recommendation is NOT to filter this into a folder. When the system sends an email, generally there is a very good reason for it.
* **notification_from_email** - arbitrary "from" address for the notification emails. Recommended to be set to "no-reply@yourcompanymaildomain.tld"
* **mail_server_relay_host** - Your SMTP relay. Must be only IP restricted/non-authenticated (for now at least!)
* **mail_server_relay_port** - Port for SMTP relay (generally 25)
* **mail_server_from_domain** - Domain used for the "FROM" email. Generally matches yourcompanymaildomain.tld.
* **ad_ldap_uri** - AD/LDAP URI. This _MUST_ be in the format: ldap://host.fqdn.tld/ (If you want TLS/SSL, you must add ```-Z``` to the scripts in the ```tools``` directory under the docker image, and re-build. In the future, we can add this as an option. Also, if you are going to use TLS/SSL make sure that your AD/LDAP servers have a certificate that includes the DNS subject alternative name, including the URI you are pointing to. Otherwise, you will need to add "TLS_REQCERT never" in /etc/openldap/ldap.conf
* **ad_ldap_searchbase** - self expalnatory. The search base. Do not try to escape, quote, etc the equivalent of: DC=oragnization,DC=fqdn,DC=tld
* **ad_ldap_binddn** - self expalnatory. The search base. Do not try to escape, quote, etc the equivlanet of: CN=ABCD,OU=Service Accounts,OU=People,DC=oragnization,DC=fqdn,DC=tld
* **ad_ldap_bindpasswd** - the AD/LDAP Bind Password

As you can clearly see by now, your lastark.cfg is "sensitive" to say the least. It is your responsibility to protect this file. This is no different from any other config file that contains secrets/passwords. This is also the reason we suggest mounting in your container as "read-only" (:ro).

# Help/Questions/Comments:
For help or more info, please open a GitHub [issue](https://github.com/harvard-itsecurity/docker-lastark/issues)

Feel free to submit improvements/PRs - the goal is to make this better and get rid of CyberArk ;)

FROM centos:7
MAINTAINER Ventz Petkov <ventz_petkov@harvard.edu>

# Temporary until EPEL RPM has our discovered bug fixed (fix already in github)
# https://bugzilla.redhat.com/show_bug.cgi?id=1564211

# When EPEL RPM is updated, normal will be
# note: make needed for NPM to build modules (ex: restify)
##RUN yum -y install epel-release && yum -y update && \
#    yum -y install lastpass-cli crontabs openldap-clients mailx postfix supervisor make && \
#    yum -y clean all && rm -Rf /var/cache/yum
RUN curl --silent --location https://rpm.nodesource.com/setup_8.x | bash - && \
    yum -y install epel-release && yum -y update && \
    yum -y update && yum -y install openssl libcurl libxml2 pinentry xclip openssl-devel libxml2-devel libcurl-devel gcc gcc-c++ make cmake wget unzip && \
    yum -y install lastpass-cli crontabs openldap-clients mailx postfix supervisor nodejs && \
    cd /tmp; wget -q https://github.com/lastpass/lastpass-cli/archive/v1.3.1.zip && unzip v1.3.1.zip && cd lastpass-cli-1.3.1 && make && make install && cd /tmp && rm -rf lastpass-cli-1.3.1 ; \
    yum remove openssl libcurl libxml2 pinentry xclip openssl-devel libxml2-devel libcurl-devel gcc gcc-c++ cmake wget unzip && yum autoremove ; \
    yum -y clean all && rm -rf /var/cache/yum

COPY crontab /etc/crontab
RUN chmod 0644 /etc/crontab ; \
    postconf -e "inet_interfaces = all" ; \
    sed -i -e '/pam_loginuid.so/s/^/#/' /etc/pam.d/crond ; \
    mkdir -p /var/log/lastark /root/lastark /root/.lpass

COPY bootstrap /
COPY init /root/
COPY lpass-askpass /root/
COPY lastark /root/lastark
COPY supervisord.conf /etc/

WORKDIR /root/lastark

VOLUME ["/root/lastark/config", "/root/lastark/users", "/var/log/lastark"];

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

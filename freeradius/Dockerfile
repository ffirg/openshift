FROM registry.access.redhat.com/rhel7

RUN yum update -y && yum -y install freeradius freeradius-ldap freeradius-utils \
    wpa_supplicant --enablerepo=rhel-7-server-optional-rpms

ADD ./templates/users /etc/raddb/users

#ADD ./templates/default.template /etc/raddb/sites-available/default
#ADD ./templates/inner-tunnel.template /etc/raddb/sites-available/inner-tunnel

EXPOSE 1812 1813 1814 18120

CMD radiusd -X

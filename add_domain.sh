#!/bin/bash

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

domain=$1
apache_virtual_server="<VirtualHost *:80>
   ServerName $domain.testing.lan
   DocumentRoot /home/$USER/public_html/$domain/
</VirtualHost>"

# Add entries to the DNS configuration files
sed -i '$a\'"${domain}"' IN A 127.0.0.1' /etc/bind/zones/testing.lan.db
sed -i '$a\1 IN PTR '"${domain}"'.testing.lan.' /etc/bind/zones/rev.0.0.127.in-addr.arpa

# Add entries to apache config files\
echo $apache_virtual_server > /etc/apache2/sites-available/$domain
a2ensite $domain

#Restart servers
invoke-rc.d bind9 restart
invoke-rc.d apache2 restart


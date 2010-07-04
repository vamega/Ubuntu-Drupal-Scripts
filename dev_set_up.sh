#$1 is the name of the folder that drupal is to be installed in.

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Initialize variables for script
drupalArchive="/home/varun/public_html/drupal-6.16.tar.gz"
domain=$1
computer_name=$(uname -n)
zones='zone "testing.lan" IN {
    type master;
    file "/etc/bind/zones/testing.lan.db";
};

zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/rev.0.0.127.in-addr.arpa";
};'
testing_lan_domain="; Use semicolons to add comments.
; Do NOT add empty lines.
; Host-to-IP Address DNS Pointers for testing.lan
; Note: The extra “.” at the end of addresses are important.
; The following parameters set when DNS records will expire, etc.
; Importantly, the serial number must always be iterated upward to prevent
; undesirable consequences. A good format to use is YYYYMMDDII where
; the II index is in case you make more that one change in the same day.
testing.lan. IN SOA $computer_name.testing.lan. $computer_name.testing.lan. (
    2008080901 ; serial
    24H ; refresh
    4H ; retry
    4W ; expire
    1D ; minimum
)
; NS indicates that $computer_name is the name server on testing.lan
; MX indicates that $computer_name is (also) the mail server on testing.lan
testing.lan. IN NS $computer_name.testing.lan.
testing.lan. IN MX 10 $computer_name.testing.lan.
; Set the address for localhost.testing.lan
localhost    IN A 127.0.0.1
"
testing_lan_reverse="; IP Address-to-Host DNS Pointers for the 127.0.0.1 subnet
@ IN SOA $computer_name.testing.lan. (
    2008080901 ; serial
    8H ; refresh
    4H ; retry
    4W ; expire
    1D ; minimum
)
; define the authoritative name server
           IN NS $computer_name.testing.lan.
; our hosts, in numeric order
1         IN PTR $computer_name.testing.lan.
"
apache_virtual_server="<VirtualHost *:80>
   ServerName $domain.testing.lan
   DocumentRoot /home/$USER/public_html/$domain/
</VirtualHost>"

#Execute Commands
tasksel install lamp-server
tasksel install dns-server
apt-get install phpmyadmin
a2enmod userdir

#Comment out the lines that turn off the php engine in userdir the php5.conf file
sed -i '/<IfModule mod_userdir.c>/,/<\/IfModule>/s/^/#/' /etc/apache2/mods-enabled/php5.conf

#Extract the drupal tarball, rename the folder, and copy the default.settings.php
mv /home/$USER/public_html/$(tar C /home/$USER/public_html/ -xvzf $drupalArchive | grep -o '^[^/]\+' | sort -u) /home/$USER/public_html/$domain
cp /home/$USER/public_html/$domain/sites/default/default.settings.php /home/$USER/public_html/$domain/sites/default/settings.php

#Set up file permissions
groupadd webdev
usermod -a -G webdev $USER
usermod -a -G webdev $www-data
chown -R $USER /home/$USER/public_html/$domain/sites/default/settings.php
chgrp -R webdev /home/$USER/public_html/$domain
chmod -R 774 /home/$USER/public_html/$domain
chmod g+s /home/$USER/public_html/$domain

#DNS Configuration Commands start here
sed -i '1i\nameserver 127.0.0.1' /etc/resolv.conf
echo "$zones" >> /etc/bind/named.conf.local
mkdir /etc/bind/zones
echo $testing_lan_domain > /etc/bind/zones/testing.lan.db
echo $testing_lan_reverse > /etc/bind/zones/rev.1.168.192.in-addr.arpa

sed -i "$a\"${domain} IN A 127.0.0.1" /etc/bind/zones/testing.lan.db
sed -i "$a\1        IN PTR ${domain}.testing.lan." /etc/bind/zones/rev.0.0.127.in-addr.arpa

#Apache Configuration files
echo $apache_virtual_server > /etc/apache2/sites-available/$domain
a2ensite $domain

#Restart servers
invokerc.d bind9 restart
invokerc.d apache2 restart

#$1 is the name of the folder that drupal is to be installed in.
# Initialize variables for script
drupalArchive = "/home/varun/public_html/drupal-6.16.tar.gz"
domain = $1

#Execute Commands
sudo tasksel install lamp-server
sudo tasksel install dns-server
sudo apt-get install phpmyadmin
sudo a2enmod userdir

#Comment out the lines that turn off the php engine in userdir the php5.conf file
sed -i '/<IfModule mod_userdir.c>/,/<\/IfModule>/s/^/#/' /etc/apache2/mods-enabled/php5.conf

#Extract the drupal tarball, rename the folder, and copy the default.settings.php
mv /home/$USERNAME/public_html/$(tar C /home/$USERNAME/public_html/ -xvzf $drupalArchive | grep -o '^[^/]\+' | sort -u) /home/$USERNAME/public_html/$domain
cp /home/$USERNAME/public_html/$domain/sites/default/default.settings.php /home/$USERNAME/public_html/$domain/sites/default/settings.php

groupadd webdev
usermod -a -G webdev $USERNAME
usermod -a -G webdev $www-data
chgrp -R webdev /home/$USERNAME/public_html/$domain
chmod -R 774 /home/$USERNAME/public_html/$domain

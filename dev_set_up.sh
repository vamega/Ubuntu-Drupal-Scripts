# Initialize variables for script

#Execute Commands
sudo tasksel install lamp-server
sudo tasksel install dns-server
sudo apt-get install phpmyadmin
sudo a2enmod userdir

#Comment out the lines that turn off the php engine in userdir the php5.conf file
sed -i '/<IfModule mod_userdir.c>/,/<\/IfModule>/s/^/#/' /etc/apache2/mods-enabled/php5.conf

groupadd webdev
usermod -a -G webdev $USERNAME
usermod -a -G webdev $www-data
chgrp -R webdev /home/$USERNAME/public_html/$1

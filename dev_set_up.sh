# Initialize variables for script

#Execute Commands
sudo tasksel install lamp-server
sudo tasksel install dns-server
sudo apt-get install phpmyadmin
sudo a2enmod userdir

#Comment out the lines that turn off the php engine in the php5.conf file
<IfModule mod_userdir\.c.+?/IfModule>

groupadd webdev
usermod -a -G webdev $USERNAME
chgrp webdev /home/$USERNAME/public_html

#!/bin/bash
apt-get update
apt-get install -y apache2
apt-get install -y php libapache2-mod-php php-mysql
sudo /etc/init.d/apache2 restart

#install unzip tool
apt-get install -y unzip
# download worpress
cd /tmp rm -rf latest.zip
wget  https://wordpress.org/latest.zip
unzip -u latest.zip

#create wp-config
cd worpress
cd wp-config-sample.php wp-config.php
#variables
DB_NAME=worpress_db
DB_USER=worpress_password
DB_PASSWORD=wordpress_password
DB_HOST=192.168.33.13

# configuramos parametros
sed -i  "s/database_name_here/$DB_NAME/" wp-config.php
sed -i  "s/username_here/$DB_USER/" wp-config.php
sed -i  "s/password_here/$DB_PASSWORD/" wp-config.php
sed -i "s/localhost/$DB_HOST/" wp-config.php

#COPY WORDPRESS files to /var/www/html
cp /tpm/wordpress/. /var/www/html/ -R

#cambiamos permisos
cd /var/www/html
chown www-data:www-data * -R

# remove index.html para que se cambie por index.php
rm /var/www/html/index.html

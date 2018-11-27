#!/bin/bash
apt-get update


#instalacion Apache HTTP Server
apt-get install -y apache2
apt-get install -y php libapache2-mod-php php-mysql
sudo /etc/init.d/apache2 restart

#Clonar repositorio de la apicacion web
cd /tmp
apt-get install -y unzip
rm -rf latest.zip
wget https://wordpress.org/latest.zip
rm -rf wordpress
unzip latest.zip
cd wordpress
cp wp-config-sample.php wp-config.php

#creamos variables pra aceder a la base de datos
DB_NAME=wordpress_db
DB_USER=wordpress_user
DB_PASSWORD=wordpress_password
DB_HOST=192.168.33.13

sed -i "s/database_name_here/$DB_NAME/" wp-config.php
sed -i "s/username_here/$DB_USER/" wp-config.php
sed -i "s/password_here/$DB_PASSWORD/" wp-config.php
sed -i "s/localhost/$DB_HOST/" wp-config.php

#movemos los archivos web del repositorio a la carpeta html para que la muestre al web y le cambiamos los permisos

cp /tmp/wordpress/. /var/www/html -R


cd /var/www/html
chown www-data:www-data * -R

#Eliminamos el index.html para que nos muestre el index.php
#rm /var/www/html/index.html 
#cp /var/www/html/wordpress/index.php /var/www/html
#sed -i 's/wp-blog-header.php/wordpress'


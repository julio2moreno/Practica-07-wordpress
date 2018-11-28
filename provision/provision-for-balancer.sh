#!/bin/bash
apt-get update
apt-get install -y apache2
apt-get install -y php libapache2-mod-php php-mysql
a2enmod proxy deflate
a2enmod proxy_http deflate
a2enmod proxy_ajp deflate
a2enmod rewrite deflate
a2enmod deflate deflate
a2enmod headers deflate
a2enmod proxy_balancer deflate
a2enmod proxy_connect deflate
a2enmod proxy_html deflate
a2enmod lbmethod_byrequests deflate
rm -f /etc/apache2/sites-enabled/000-default.conf
cd /etc/apache2/sites-enabled
sudo cp /vagrant/config/000-default.conf .
sudo /etc/init.d/apache2 restart
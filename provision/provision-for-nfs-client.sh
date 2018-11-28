#/bin/bash

#include provision-for-apache.sh
source /vagrant/provision/provision-for-apache.sh

#install 
sudo apt-get update #esto puede ser opcional ya que en el source de arriba se hace update
sudo apt-get install -y  nfs-common

#mount wp-content
mount 192.168.33.11:/var/www/html/wp-content /var/www/html/wp-content

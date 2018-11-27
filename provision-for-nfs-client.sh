source /vagrant/provision/provision-for-apache.sh

#instalamoslos servicios nfs para el server.

apt-get update
apt-get install -y nfs-common

#mount wp-content

mount 192.168.33.11:/var/www/html/wp-content /var/www/html/wp-content

#copiamos 
cp vagrant/config/fstabs /etc -f


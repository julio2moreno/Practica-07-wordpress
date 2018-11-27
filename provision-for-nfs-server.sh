#incluimos provision-for-apache.sh
source /vagrant/provision/provision-for-apache.sh

#instalamoslos servicios nfs

apt-get update
apt-get install -y nfs-kernel-server

#exportamos directorio y cambiamos los permisos 

chwon nobody:nogroup /var/www/html/wp-content

#editamos el archhivo /etc/exports y le damos permisos.

cp /vagrant/config/exports /etc/ -f

#reinciio nfs server

/etc/init.d/nfs-kernel-server restart
#/bin/bash
set -x
# include provision-for-apache.sh
source /vagrant/provision/provision-for-apache.sh
# instalamos -nfs-server
sudo apt-get update
sudo apt-get install -y nfs-kernel-server

# cambiamos permisos
chown nobody:nogroup /var/www/html/wp-content

# copy exports file
cp /var/config/exports /etc/ -f 

# reinicio
/etc/init.d/nfs-kernel-server restart



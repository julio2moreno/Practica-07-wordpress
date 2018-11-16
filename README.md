# Practica-07_wordpress
###### Vamos a usar Vagrant para automatizar la creación de una infraestructura de pruebas donde se ejecutará WordPress.
###### La arquitectura y el conjunto de direcciones IPs que tendrán las máquinas virtales son:
###### + Un balanceador de carga con la IP: (192.168.33.10) 
###### + Una capa de front-end, formada por dos servidores web con Apache HTTP Server: *Frontal Web 1*  IP: (192.168.33.11) *Frontal Web 2*
###### IP: (192.168.33.12)
###### + Una capa de back-end, formada por un servidor de Base de Datos MySQL: IP: (192.168.33.13)


## Creacion de Vagrantfile
Creamos una carpeta donde van a estar ubicadas las maquinas virtuales.

Dentro del directorio creamos el archivo vagrantfile ``vagrant init`` y lo abrimos ``code vagrantfile``.

En el archivo ``vagrantfile`` vamos a poner la instalacion de las maquinas virtuales:

````
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/bionic64"

  # Apache HTTP Server Balanceador de Carga
  config.vm.define "balancer" do |app|
    app.vm.hostname = "balancer"
    app.vm.network "private_network", ip: "192.168.33.10"
    app.vm.provision "shell", path: "provision/provision-for-balancer.sh"
  end
  
  # Apache HTTP Server
  config.vm.define "web1" do |app|
    app.vm.hostname = "web1"
    app.vm.network "private_network", ip: "192.168.33.11"
    app.vm.provision "shell", path: "provision/provision-for-apache.sh"
  end

  # Apache HTTP Server2
  config.vm.define "web2" do |app|
    app.vm.hostname = "web2"
    app.vm.network "private_network", ip: "192.168.33.12"
    app.vm.provision "shell", path: "provision/provision-for-apache.sh"
  end

  # MySQL Server
  config.vm.define "db" do |app|
    app.vm.hostname = "db"
    app.vm.network "private_network", ip: "192.168.33.13"
    app.vm.provision "shell", path: "provision/provision-for-mysql.sh"
  end

end
````
Ahora vamos a crear dos carpetas para organizar mejor los datos y tener la ubicacion de los archivos mas controlado.
creamos la carpeta ``config`` donde meteremos el archivo ``000-default.conf``, ``exports`` y ``fstab`` que esto lo vamos a utilizar para sincronizar el contenido estatico de la capa Front-End y otra carpeta ``provision`` para meter los archivos ``provision`` de las maquinas virtuales.

En el archivo ``000-default.conf`` vamos a poner la siguiente configuracion:
````
<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
    <Proxy balancer://mycluster>
        # Server 1
        BalancerMember http://192.168.33.11

        # Server 2
        BalancerMember http://192.168.33.12
    </Proxy>
    ProxyPass / balancer://mycluster/
</VirtualHost>

````

Dentro del archivo ``exports`` debemos tener:
````
/var/www/html      192.168.33.12(rw,sync,no_root_squash,no_subtree_check)
````
En el archivo ``fstab`` debemos tener configurado:
````
LABEL=clouding-rootfst  /   ext4    defaults    0 0
192.168.33.11:/var/www/html /var/www/html  nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
````


## Creacion de los archivos ``provision`` donde configurar y crear todas las máquinas virtuales que hemos seleccionado en el ``Vagrantfile``.

Dentro de la carpeta ``provision`` debemos de tener tres archivos.

1.-``provision-for-apache-sh``:
````
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
````

2.-``provision-for-mysql.sh``:
````
#!/bin/bash
apt-get update
apt-get -y install debconf-utils

DB_ROOT_PASSWD=root
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DB_ROOT_PASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DB_ROOT_PASSWD"

apt-get install -y mysql-server
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
/etc/init.d/mysql restart

mysql -u root mysql -p$DB_ROOT_PASSWD <<< "GRANT ALL PRIVILEGES ON *.* TO root@'%' IDENTIFIED BY '$DB_ROOT_PASSWD'; FLUSH PRIVILEGES;"

#create wordpress database
DB_NAME=wordpress_db
DB_USER=wordpress_user
DB_PASSWORD=wordpress_password
mysql -u root mysql -p$DB_ROOT_PASSWD <<< "DROP DATABASE IF EXISTS $DB_NAME;"
mysql -u root mysql -p$DB_ROOT_PASSWD <<< "CREATE DATABASE $DB_NAME CHARACTER SET utf8;"
mysql -u root mysql -p$DB_ROOT_PASSWD <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@'%' IDENTIFIED BY '$DB_PASWORD';"
mysql -u root mysql -p$DB_ROOT_PASSWD <<< "FLUSH PRIVILEGES;"
````
3.- ``provision-for-balance``:
````
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
````


## Sincronización en la capa de Front-End mediante NFS
Creamos un cliente y un servidor NFS que lo meteremos dentro de la carpeta ``provision`` uno se va a llamar ``provision-for-nfs-client.sh`` y otro que se va a llamar ``provision-for-nfs.server.sh``.

#### 1.-El archivo  ``provision-for-nfs.server.sh`` debe contener:
````
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
````
#### 2.- El archivo  ``provision-for-nfs.client.sh`` debe contener:
````
#/bin/bash

#include provision-for-apache.sh
source /vagrant/provision/provision-for-apache.sh

#install 
sudo apt-get update #esto puede ser opcional ya que en el source de arriba se hace update
sudo apt-get install -y  nfs-common

#mount wp-content
mount 192.168.33.11:/var/www/html/wp-content /var/www/html/wp-content
````


## Comandos utiles 
Para iniciar las maquinas ``vagrant up web`` y ``vagrant up db``.

Hacemos un ``vagrant provision`` para actualizar.

Para acceder ``vagrant ssh web`` o ``vagrant ssh db``

Para ver las maquinas que tenemos iniciadas ``vagrant status`` ó ``vagrant global-status``








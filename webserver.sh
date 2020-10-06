#!/bin/bash

#instalasi paket yang dibutuhkan (LAMP Stack)
apt update
apt-get -y install apache2 
apt-get -y install mysql-server 
apt-get -y install php php-mysql libapache2-mod-php php-cli

#mengcopy file index.php ke direktori root apache
rm -rf /var/www/html/index.html
cp index.php /var/www/html

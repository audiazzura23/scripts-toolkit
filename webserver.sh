#!/bin/bash

#instalasi paket yang dibutuhkan
apt update
apt-get -y install apache2
apt-get install php-cli

#mengcopy file index.php ke folder root apache
rm -rf /var/www/html
cp index.php /var/www/html

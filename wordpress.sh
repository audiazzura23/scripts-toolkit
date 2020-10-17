#!/bin/bash

#get current directory
pwd=$(pwd)

#variables to be used for db
read -p 'wordpress_db_name [wp_db]: ' wordpress_db_name
read -p 'db_root_username [only-alphanumeric]: ' db_root_username
read -p 'db_root_password [only-alphanumeric]: ' db_root_password
read -p 'db_host [for default, type:localhost]: ' db_host
echo

#lamp stack installation
apt -y update
apt -y install apache2
apt -y install mysql-server
apt-get -y install php php-mysql libapache2-mod-php php-cli php-cgi php-gd

#makes sure lamp stack running
systemctl start apache2
systemctl start mysql

#mysql secure install 
mysql --user=root <<_EOF_
UPDATE mysql.user SET authentication_string = PASSWORD('$db_root_password') WHERE User='root';
UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE User = 'root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_

#wordpress installation
rm /var/www/html/index.*
apt -y install wget
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
cp -r wordpress/* /var/www/html

#apache restart
systemctl restart apache2

#set kepemilikan dan permissions  
chown -R www-data:www-data /var/www/

#mysql config for wordpress
mysql -u root -p $db_root_password <<QUERY_INPUT
CREATE DATABASE $wordpress_db_name;
CREATE USER "$wordrpress_db_username"@"db_host" IDENTIFIED BY '$db_root_password';
GRANT ALL PRIVILEGES ON $wordpress_db_name.* TO '$wordpress_db_username'@'db_host' IDENTIFIED BY '$db_root_password';
FLUSH PRIVILEGES;
EXIT;
QUERY_INPUT
   
#cleaning
cd $pwd  
rm -rf latest.tar.gz wordpress  
   
echo "Installation is Complete"
echo

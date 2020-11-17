#!/bin/bash

#get current directory
pwd=$(pwd)

#variables to be used for db
echo ""
echo ">>>>>>>>>>>>>>>>> Remember these settings <<<<<<<<<<<<<<<<<"
echo ">>>>> it will be needed to complete the installations <<<<<"
echo ""
read -p 'Database Name for Wordpress (alphaumeric only): ' wordpress_db_name
read -p 'Database Root Username (alphanumeric only): ' db_root_username
read -p 'New Database Root Password (alphanumeric and symbols): ' db_root_password
read -p 'Database Host (for default, type:localhost): ' db_host
echo ""

#lamp stack installation
apt -y update
apt -y install apache2
apt -y install mysql-server
apt -y install php php-mysql libapache2-mod-php php-cli php-cgi php-gd

#making sure lamp stack is running
systemctl start apache2
systemctl start mysql

#mysql secure install
mysql -e "SET PASSWORD FOR root@localhost = PASSWORD('temp');FLUSH PRIVILEGES;" 
mysql -uroot -ptemp <<_EOF_
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

#set ownership and permissions
chown -R www-data:www-data /var/www/

#mysql config for wordpress
mysql -uroot -p$db_root_password <<_EOF_
CREATE DATABASE $wordpress_db_name;
CREATE USER '$db_root_username'@'$db_host' IDENTIFIED BY '$db_root_password';
GRANT ALL PRIVILEGES ON $wordpress_db_name.* TO $db_root_username@$db_host IDENTIFIED BY '$db_root_password';
FLUSH PRIVILEGES;
_EOF_

#cleaning
cd $pwd
rm -rf latest.tar.gz wordpress
echo ""
echo "========== Go to Your IP Address to Complete the Installation =========="
echo ""

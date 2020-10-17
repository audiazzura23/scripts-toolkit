#!/bin/bash

#cek direktori
pwd=$(pwd) 

#input root password  mysql 
read -p 'wordpress_db_name [wp_db]: ' wordpress_db_name  
read -p 'db_root_password [only-alphanumeric]: ' db_root_password  
echo 

#instalasi paket yang dibutuhkan (LAMP Stack)
apt-get -y update
apt-get -y install apache2 apache2-utils
apt-get -y install mysql-server 
apt-get -y install php php-mysql libapache2-mod-php php-cli

#jalankan apache
systemctl start apache2  
systemctl enable apache2  
   
#install MySQL database server  
export DEBIAN_FRONTEND="noninteractive"  
debconf-set-selections <<< "mysql-server mysql-server/root_password password $db_root_password"  
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $db_root_password"  
apt-get install mysql-server mysql-client -y  
   
#install Latest WordPress  
rm /var/www/html/index.*  
wget -c http://wordpress.org/latest.tar.gz  
tar -xzvf latest.tar.gz  
rsync -av wordpress/* /var/www/html/  
   
#set kepemilikan dan permissions  
chown -R www-data:www-data /var/www/html/  
chmod -R 755 /var/www/html/  
   
#konfigurasi database wordpress
mysql -uroot -p$db_root_password <<QUERY_INPUT  
CREATE DATABASE $wordpress_db_name;  
GRANT ALL PRIVILEGES ON $wordpress_db_name.* TO 'root'@'localhost' IDENTIFIED BY '$db_root_password';  
FLUSH PRIVILEGES;  
EXIT  
QUERY_INPUT  
   
#input data db ke config wordpress
cd /var/www/html/  
sudo mv wp-config-sample.php wp-config.php  
perl -pi -e "s/database_name_here/$wordpress_db_name/g" wp-config.php  
perl -pi -e "s/username_here/root/g" wp-config.php  
perl -pi -e "s/password_here/$db_root_password/g" wp-config.php  
   
# Enabling Mod Rewrite  
a2enmod rewrite  
php5enmod mcrypt  
   
#instalasi phpmyadmin
apt-get install phpmyadmin -y  
   
#konfigurasi phpmyadmin
echo 'Include /etc/phpmyadmin/apache.conf' >> /etc/apache2/apache2.conf  
   
#restart apache dan mysql
service apache2 restart  
service mysql restart  
   
#cleaning
cd $pwd  
rm -rf latest.tar.gz wordpress  
   
echo "Installation is Complete"  
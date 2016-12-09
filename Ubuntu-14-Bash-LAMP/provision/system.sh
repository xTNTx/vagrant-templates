#!/bin/bash
set -x

echo "Fixing language ..."
export LANGUAGE="en_US.UTF-8"
echo 'LANGUAGE="en_US.UTF-8"' >> /etc/default/locale
echo 'LC_ALL="en_US.UTF-8"' >> /etc/default/locale

echo "Updating packages repo ..."
apt-get update

echo "Installing basic tools ..."
apt-get install -y mc git vim python-software-properties

echo "Installing PHP and Ko ..."
add-apt-repository ppa:ondrej/php5-5.6
apt-get update
apt-get install -y php5 php5-mcrypt php5-curl php5-gd php5-xdebug

echo "Configuring PHP ..."
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini
echo "
xdebug.remote_enable=1
xdebug.remote_host=192.168.2.1
xdebug.remote_port=9000
" >> /etc/php5/mods-available/xdebug.ini

echo "Configuring Apache ..."
a2enmod rewrite
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
sed -i "s/Require all denied/Require all granted/g" /etc/apache2/apache2.conf
echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf
a2enconf servername
service apache2 restart

echo "Installing MySQL ..."
apt-get install debconf-utils
debconf-set-selections <<< "mysql-server mysql-server/root_password password 123456"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password 123456"
apt-get install -y mysql-server php5-mysql

echo "Configuring MySQL ..."
mysql -u root -p123456 -e "UPDATE mysql.user SET Password = '' WHERE User = 'root'; FLUSH PRIVILEGES;"
mysql -e "CREATE USER 'root'@'%'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
mysql -e "CREATE USER 'vagrant'@'localhost'; GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'localhost' WITH GRANT OPTION;"
sed -i 's/bind-address/# bind-address/' /etc/mysql/my.cnf
service mysql restart

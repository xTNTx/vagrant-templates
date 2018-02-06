#!/usr/bin/env bash
set -x
export DEBIAN_FRONTEND=noninteractive

echo "Fixing language ..."
export LANGUAGE="en_US.UTF-8"
echo 'LANGUAGE="en_US.UTF-8"' >> /etc/default/locale
echo 'LC_ALL="en_US.UTF-8"' >> /etc/default/locale

echo "Configuring system ..."
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

echo "Adding repos"
add-apt-repository ppa:ondrej/php -y
add-apt-repository ppa:nginx/stable -y
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 5072E1F5
echo "deb http://repo.mysql.com/apt/ubuntu/ trusty mysql-5.7" | tee -a /etc/apt/sources.list.d/mysql.list

echo "Updating repo and packages ..."
apt-get update && apt-get upgrade -y

echo "Installing basic tools ..."
apt-get install -y mc git vim python-software-properties

echo "Installing Nginx ..."
apt-get install -y nginx

echo "Configuring Nginx ..."
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
sed -i "s/user www-data;/user vagrant;/" /etc/nginx/nginx.conf
sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf
service nginx restart
usermod -a -G www-data vagrant

echo "Installing PHP and Ko ..."
apt-get install -y php7.1-fpm php7.1-mcrypt php7.1-curl php7.1-gd php7.1-mbstring php7.1-xdebug php7.1-mysql php7.1-sqlite3 php7.1-xml

echo "Configuring PHP ..."
sed -i "s/user = www-data/user = vagrant/" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = vagrant/" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.1/fpm/pool.d/www.conf

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.1/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.1/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.1/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.1/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.1/fpm/php.ini

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/cli/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/cli/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.1/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.1/cli/php.ini

echo "
xdebug.remote_enable = 1
xdebug.remote_autostart = 1
xdebug.remote_connect_back = 1
xdebug.remote_port = 9000
" >> /etc/php/7.1/fpm/conf.d/20-xdebug.ini
service php7.1-fpm restart

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

echo "Installing MySQL ..."
apt-get install -y mysql-server

echo "Configuring MySQL ..."
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';"
mysql -e "CREATE USER 'root'@'%'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
mysql -e "CREATE USER 'vagrant'@'localhost'; GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'localhost' WITH GRANT OPTION;"
sed -i 's/bind-address/# bind-address/' /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart
#mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql mysql

echo "Installing NodeJS ..."
curl -sL https://deb.nodesource.com/setup_8.x | bash -
apt-get install -y nodejs

echo "Installing iTerm2 integration ..."
curl -L https://iterm2.com/misc/install_shell_integration.sh | bash

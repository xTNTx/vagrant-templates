#!/bin/bash
set -x

PROJECT=$1
WEB_ROOT=$2
if [ ! -n "$PROJECT" ]; then
    echo "Project name argument is missing!"
    exit 1
fi
if [ ! -n "$WEB_ROOT" ]; then
    echo "Web root argument is missing!"
    exit 1
fi

cd /vagrant

echo "Setting up main project ..."
echo "<VirtualHost *:80>
    ServerAdmin admin@$PROJECT.loc
    ServerName $PROJECT.loc
    ServerAlias www.$PROJECT.loc
    DocumentRoot /vagrant/site
    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined
</VirtualHost>" | sudo tee /etc/apache2/sites-available/${PROJECT}.loc.conf
sudo a2ensite ${PROJECT}.loc.conf

sudo service apache2 restart

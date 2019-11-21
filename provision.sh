#!/bin/bash

#update package manager
apt-get update -y

#install nginx
apt-get install nginx -y

#remove and replace default file in nginx
apt-get update -y
rm /etc/nginx/sites-available/default
cp /vagrant/default /etc/nginx/sites-available


#install php dependencies
apt-get update -y
add-apt-repository ppa:ondrej/php -y
apt-get install python-software-properties build-essential -y

#install php
apt-get update -y
apt-get install php7.2 php7.2-curl php7.2-dev php7.2-gd php7.2-mbstring php7.2-zip php7.2-mysql php7.2-xml
rm /etc/php/7.2/fpm/pool.d/www.conf
cp /vagrant/www.conf /etc/php/7.2/fpm/pool.d

#install debconf to bypass mysqlserver prompts and install mysql-server
apt-get update -y
apt-get install debconf-utils -y
debconf-set-selections <<< "mysql-server mysql-server/root_password password mysql"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password mysql"
apt-get install mysql-server -y

#install phpmyadmin and bypass phpmyadmin installation prompts with defconf-utils
apt-get update -y
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password mysql"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password mysql"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password mysql"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"
apt-get install phpmyadmin -y

#link phpmyadmin with host
apt-get update -y
phpenmod php7.2-mbstring
ln -s /usr/share/phpmyadmin /vagrant/www

#restart nginx and php 
service nginx restart
service php7.2-fpm restart
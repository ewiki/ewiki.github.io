#! /bin/bash

cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
echo 'export LC_ALL=C' | tee -a ~/.bashrc
source ~/.bashrc
echo 'AddressFamily inet' | tee -a /etc/ssh/sshd_config

sed -i '1,$d' /etc/default/locale
echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\nLC_ALL="en_US.UTF-8"' | tee -a /etc/default/locale

sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 60/g' /etc/ssh/sshd_config
systemctl restart sshd
apt update && apt upgrade -y

#install nginx
apt install nginx -y
systemctl start nginx
systemctl enable nginx

#install php
apt install php7.3-cli php7.3-fpm php7.3-bcmath php7.3-mysql php7.3-curl php7.3-gd php7.3-imagick php7.3-intl php7.3-mbstring php7.3-xmlrpc php7.3-xsl php7.3-dev zip php7.3-zip php-pear php7.3-soap php7.3-xml -y

sed -i 's/;date.timezone \=/date.timezone \= America\/Los_Angeles/g' /etc/php/7.3/fpm/php.ini && sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.3/fpm/php.ini && sed -i "s/memory_limit = .*/memory_limit = 1G/" /etc/php/7.3/fpm/php.ini && sed -i "s/upload_max_filesize = .*/upload_max_filesize = 128M/" /etc/php/7.3/fpm/php.ini && sed -i "s/zlib.output_compression = .*/zlib.output_compression = On/" /etc/php/7.3/fpm/php.ini && sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/7.3/fpm/php.ini && sed -i 's/;opcache.save_comments=1/opcache.save_comments=1/g' /etc/php/7.3/fpm/php.ini && sed -i 's/;opcache.enable=1/opcache.enable=1/g' /etc/php/7.3/fpm/php.ini && sed -i "s/short_open_tag = .*/short_open_tag = On/" /etc/php/7.3/fpm/php.ini

sed -i 's/;date.timezone \=/date.timezone \= America\/Los_Angeles/g' /etc/php/7.3/cli/php.ini && sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.3/cli/php.ini && sed -i "s/memory_limit = .*/memory_limit = 1G/" /etc/php/7.3/cli/php.ini && sed -i "s/upload_max_filesize = .*/upload_max_filesize = 128M/" /etc/php/7.3/cli/php.ini && sed -i "s/zlib.output_compression = .*/zlib.output_compression = On/" /etc/php/7.3/cli/php.ini && sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/7.3/cli/php.ini && sed -i 's/;opcache.save_comments=1/opcache.save_comments=1/g' /etc/php/7.3/cli/php.ini && sed -i 's/;opcache.enable=1/opcache.enable=1/g' /etc/php/7.3/cli/php.ini && sed -i "s/short_open_tag = .*/short_open_tag = On/" /etc/php/7.3/cli/php.ini

systemctl start php7.3-fpm
systemctl enable php7.3-fpm
systemctl status php7.3-fpm

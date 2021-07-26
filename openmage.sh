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

#以下非自动化部署代码

四. MySQL

apt install curl wget gnupg2 -y
***官网最新版本https://dev.mysql.com/downloads/repo/apt/***
wget https://dev.mysql.com/get/mysql-apt-config_0.8.16-1_all.deb
dpkg -i mysql-apt-config_0.8.16-1_all.deb
apt update
apt install mysql-server -y
5PB8yj9E3vuH99G7m7KEnqNq
mysql_secure_installation
systemctl status mysql
systemctl enable mysql

mysql -u root -p
5PB8yj9E3vuH99G7m7KEnqNq
SELECT user,authentication_string,plugin,host FROM mysql.user;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '5PB8yj9E3vuH99G7m7KEnqNq';
SELECT user,authentication_string,plugin,host FROM mysql.user;
exit

为Magento 2创建新的MySQL用户（数据库密码最好不要带特殊字符）
mysql -u root -p
SELECT user,authentication_string,plugin,host FROM mysql.user;
CREATE USER 'psvane'@'localhost' IDENTIFIED BY '28ymn8iAX3XSq2t13u3FHMpN';
ALTER USER 'psvane'@'localhost' IDENTIFIED WITH mysql_native_password BY '28ymn8iAX3XSq2t13u3FHMpN';
GRANT ALL PRIVILEGES ON *.* TO 'psvane'@'localhost' WITH GRANT OPTION;
SELECT user,authentication_string,plugin,host FROM mysql.user;
exit

创建Magento 2的数据库
mysql -u psvane -p
CREATE DATABASE psvane;
exit

五. 安装前的准备

设置虚拟主机

vim /etc/nginx/sites-available/magento.conf
----------------------------------------------------------------------
server {
    listen 80 default_server;

    server_name www.psvanetubes.com psvanetubes.com;
    root /var/www/magento/;

    location / {
        index   index.html  index.php;
        try_files $uri $uri/ @handler;
        expires 30d;
    }

    ## These locations would be hidden by .htaccess normally
    location /app/                { deny all; }
    location /includes/           { deny all; }
    location /lib/                { deny all; }
    location /media/downloadable/ { deny all; }
    location /pkginfo/            { deny all; }
    location /report/config.xml   { deny all; }
    location /var/                { deny all; }


    ## Disable .htaccess and other hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    location @handler {
        rewrite / /index.php;
    }

    location ~ \.php/ {
        rewrite ^(.*\.php)/ $1 last;
    }

    location ~ \.php$ {
        if (!-e $request_filename) {
            rewrite / /index.php last;
        }

        expires         off;
        fastcgi_pass    unix:/run/php/php7.3-fpm.sock;
        include         snippets/fastcgi-php.conf;
    }
}

-------------------------------------------------------------------------
ln -s /etc/nginx/sites-available/magento.conf /etc/nginx/sites-enabled/
wget安装包
来自：.https://github.com/OpenMage/magento-lts/releases

rm /etc/nginx/sites-available/default
rm /etc/nginx/sites-enabled/default

systemctl restart nginx
systemctl restart php7.3-fpm

安装SSL
apt install snapd -y
snap install core; snap refresh core
apt-get remove certbot
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
certbot --nginx -d www.psvanetubes.com -d psvanetubes.com
certbot renew --dry-run

更改目录和文件权限
chown -R :www-data . 

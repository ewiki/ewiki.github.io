#! /bin/bash

apt install nginx -y
systemctl start nginx
systemctl enable nginx

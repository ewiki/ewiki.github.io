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

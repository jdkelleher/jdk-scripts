#!/bin/bash
#
usage() {
	echo "usage : $0 <new hostname>"
	exit 1
}

[ "$1" ] || usage

old=$(hostname)
new=$1

# update common files in /etc
for file in \
	/etc/hostname \
	/etc/hosts \
	/etc/ssh/ssh_host_rsa_key.pub \
	/etc/ssh/ssh_host_dsa_key.pub \
	/etc/motd \
	/etc/printcap \
	/etc/mailname \
	/etc/exim4/update-exim4.conf.conf \
	/etc/ssmtp/ssmtp.conf
do
   [ -f $file ] && sed -i.old -e "s:$old:$new:g" $file
done

# Set Hostname - should check for systemd
hostname $new
hostnamectl set-hostname $new

# regenerate ssh config and keys - should verify openssh-server is installed
rm /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server


# Clean Up
apt-get clean
rm -f /var/log/*
rm -f /root/.bash_history /admin-user/.bash_history 


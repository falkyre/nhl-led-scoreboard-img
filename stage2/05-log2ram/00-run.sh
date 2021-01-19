#!/bin/bash -e

on_chroot << EOF
#Install log2ram to have all /var/log files written to ram disk
echo "deb http://packages.azlux.fr/debian/ buster main" | tee /etc/apt/sources.list.d/azlux.list
wget -qO - https://azlux.fr/repo.gpg.key | apt-key add -
apt update
apt install log2ram
EOF

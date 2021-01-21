#!/bin/bash -e
#install base files
install -v -d "${ROOTFS_DIR}/usr/lib/raspiwifi"
install -v -d "${ROOTFS_DIR}/etc/raspiwifi"
install -v -d "${ROOTFS_DIR}/etc/cron.raspiwifi"
cp -a files/lib/* "${ROOTFS_DIR}/usr/lib/raspiwifi/"
install -v -m 644 "files/etc/raspiwifi/raspiwifi.conf" "${ROOTFS_DIR}/etc/raspiwifi/"
install -v -m 644 "files/sb_raspiwifi.service" "${ROOTFS_DIR}/etc/systemd/system/"
install -v -m 755 "files/first_run.sh" "${ROOTFS_DIR}/usr/lib/raspiwifi/"

on_chroot << EOF
#Install packages to create hostap
apt install dnsmasq hostapd -y

#Install pip requirements for web app
pip3 install pyyaml
pip3 install flask pyopenssl

#Set up hostap for initial run
# This is done with the sb_raspiwifi.service
systemctl unmask sb_raspiwifi
systemctl enable sb_raspiwifi

EOF

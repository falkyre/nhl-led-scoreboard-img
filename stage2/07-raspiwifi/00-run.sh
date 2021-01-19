#!/bin/bash -e
#install base files
install -v -d "${ROOTFS_DIR}/usr/lib/raspiwifi"
install -v -d "${ROOTFS_DIR}/etc/raspiwifi"
cp -a files/libs/* "${ROOTFS_DIR}/usr/lib/raspiwifi/"
install -v -m 644 "files/etc/raspiwifi.conf" "${ROOTFS_DIR}/etc/raspiwifi/"

on_chroot << EOF
#Install packages to create hostap
apt install dnsmasq hostapd -y

#Install pip requirements for web app
pip3 install pyyaml
pip3 install flask pyopenssl

#Set up hostap for initial run

#mkdir /usr/lib/raspiwifi
#mkdir /etc/raspiwifi
#cp -a files/libs/* /usr/lib/raspiwifi/
mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.original
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.original
cp /usr/lib/raspiwifi/reset_device/static_files/dnsmasq.conf /etc/
cp /usr/lib/raspiwifi/reset_device/static_files/hostapd.conf.wpa /etc/hostapd/hostapd.conf
mv /etc/dhcpcd.conf /etc/dhcpcd.conf.original
cp /usr/lib/raspiwifi/reset_device/static_files/dhcpcd.conf /etc/
mkdir /etc/cron.raspiwifi
cp /usr/lib/raspiwifi/reset_device/static_files/aphost_bootstrapper /etc/cron.raspiwifi
chmod +x /etc/cron.raspiwifi/aphost_bootstrapper
echo "# RaspiWiFi Startup" >> /etc/crontab
echo "@reboot root run-parts /etc/cron.raspiwifi/" >> /etc/crontab
#mv /usr/lib/raspiwifi/reset_device/static_files/raspiwifi.conf /etc/raspiwifi
touch /etc/raspiwifi/host_mode

EOF

#!/bin/bash

File="/etc/wpa_supplicant/wpa_supplicant.conf"
if ! grep -q "network=" "$File"; then
   /usr/sbin/rfkill unblock wifi
   mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.original
   mv /etc/dnsmasq.conf /etc/dnsmasq.conf.original
   cp /usr/lib/raspiwifi/reset_device/static_files/dnsmasq.conf /etc/
   cp /usr/lib/raspiwifi/reset_device/static_files/hostapd.conf.wpa /etc/hostapd/hostapd.conf
   mv /etc/dhcpcd.conf /etc/dhcpcd.conf.original
   cp /usr/lib/raspiwifi/reset_device/static_files/dhcpcd.conf /etc/
   #cp -f /usr/lib/raspiwifi/reset_device/static_files/aphost_bootstrapper /etc/cron.raspiwifi
   cat /usr/lib/raspiwifi/reset_device/static_files/aphost_bootstrapper > /etc/cron.raspiwifi/aphost_bootstrapper
   chmod +x /etc/cron.raspiwifi/aphost_bootstrapper
   echo "# RaspiWiFi Startup" >> /etc/crontab
   echo "@reboot root run-parts /etc/cron.raspiwifi/" >> /etc/crontab
   #mv /usr/lib/raspiwifi/reset_device/static_files/raspiwifi.conf /etc/raspiwifi
   touch /etc/raspiwifi/host_mode
fi


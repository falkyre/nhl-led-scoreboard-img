#!/bin/bash

File="/etc/wpa_supplicant/wpa_supplicant.conf"
if ! grep -q "network=" "$File"; then
   /usr/sbin/rfkill unblock wifi
   mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.original
   mv /etc/dnsmasq.conf /etc/dnsmasq.conf.original
   cp /usr/lib/raspiwifi/reset_device/static_files/dnsmasq.conf /etc/
   cp /usr/lib/raspiwifi/reset_device/static_files/hostapd.conf.wpa /etc/hostapd/hostapd.conf
   # Update the base hostapd.conf file with the last 4 characters of the serial for the SSID
   last4serial=`cat /sys/firmware/devicetree/base/serial-number | awk '{print substr($1,length($1)-3) }'`
   sed -i "/NHL LED Scoreboard/ s/$/ $last4serial/" /etc/hostapd/hostapd.conf
   #update the hostname of the raspberry pi
   sed -i "/scoreboard/s/$/-$last4serial/" /etc/hostname
   sed -i "/scoreboard/s/$/-$last4serial/" /etc/hosts
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


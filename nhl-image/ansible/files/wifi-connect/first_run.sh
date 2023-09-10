#!/bin/bash

export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket

/usr/sbin/rfkill unblock wifi

last4serial=`cat /sys/firmware/devicetree/base/serial-number | awk '{print substr($1,length($1)-4) }'`
#update the hostname of the raspberry pi
sed -i "/scoreboard/s/$/-$last4serial/" /etc/hostname
sed -i "/scoreboard/s/$/-$last4serial/" /etc/hosts

# Optional step - it takes couple of seconds (or longer) to establish a WiFi connection
# sometimes. In this case, following checks will fail and wifi-connect
# will be launched even if the device will be able to connect to a WiFi network.
# If this is your case, you can wait for a while and then check for the connection.
# sleep 15

# Choose a condition for running WiFi Connect according to your use case:

# 1. Is there a default gateway?
# ip route | grep default

# 2. Is there Internet connectivity?
# nmcli -t g | grep full

# 3. Is there Internet connectivity via a google ping?
# wget --spider http://google.com 2>&1

# 4. Is there an active WiFi connection?
/usr/sbin/iwgetid -r

if [ $? -eq 0 ]; then
    printf 'Skipping WiFi Connect\n'
else
    printf 'Starting WiFi Connect\n'
    /usr/local/sbin/wifi-connect -s "NHL LED Scoreboard $last4serial" -u /root/wificonnect/scoreboard_wc_ui
fi

touch /etc/wificonnect/host_mode
rm /etc/wificonnect/ap_mode

sleep 5

/usr/sbin/reboot
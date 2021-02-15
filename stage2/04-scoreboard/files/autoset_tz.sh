#!/bin/sh
#Automatically set timezone
zone=$(/usr/bin/wget -O - -q http://geoip.ubuntu.com/lookup | sed -n -e 's/.*<TimeZone>\(.*\)<\/TimeZone>.*/\1/ p')
current_tz=$(/usr/bin/timedatectl show -p Timezone --value)

if [ "$zone" != "" ] && [ "$zone" != "$current_tz" ] ;then
    /usr/bin/timedatectl set-timezone $zone 
    #Check to see if the setTZ file exists and delete it 
    #This is for when run from the autostart service on boot
    if [ -f "/home/pi/.nhlledportal/setTZ" ]; then
       rm /home/pi/.nhlledportal/setTZ
    fi
    echo "Timezone set to $zone for your location"
else
	echo "Timezone $current_tz already set correctly for your location found($zone)"
fi


#!/bin/bash -e

on_chroot << EOF


CURRENTLY_BUILT_VER=`cat /home/pi/nhl-led-scoreboard/VERSION`
echo "You are running the latest version V${CURRENTLY_BUILT_VER}" > /home/pi/.nhlupdate/status

chown -R pi:pi .nhlupdate

EOF

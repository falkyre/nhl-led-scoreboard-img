#!/bin/bash -e

on_chroot << EOF
#Install pip requirements for scoreboard

pip3 install --upgrade pip
pip3 install requests
pip3 install regex
pip3 install geocoder python_tsl2591 ephem
pip3 uninstall numpy
pip3 install env-canada==0.0.35
pip3 install --upgrade pyowm
pip3 install noaa_sdk fastjsonschema
pip3 install apscheduler
pip3 install lastversion
pip3 install numpy

#Clone scoreboard repo
cd /home/pi
git clone https://github.com/riffnshred/nhl-led-scoreboard.git

cd nhl-led-scoreboard
#Install rgb matrix
# Pull submodule and ignore changes from script
git submodule update --init --recursive
git config submodule.matrix.ignore all

cd submodules/matrix 

make build-python PYTHON=$(which python3)
sudo make install-python PYTHON=$(which python3)
cd bindings
pip3 install -e python/

cd /home/pi
chown -R pi:pi nhl-led-scoreboard

EOF

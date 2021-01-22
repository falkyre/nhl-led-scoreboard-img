#!/bin/bash -e
install -v -d ${ROOTFS_DIR}/home/pi/sbtools
install -v -m 755 files/checkUpdate.sh ${ROOTFS_DIR}/home/pi/sbtools
install -v -m 755 files/issueUpload.sh ${ROOTFS_DIR}/home/pi/sbtools

on_chroot << EOF
#Remove packages that might impact performance as per https://github.com/hzeller/rpi-rgb-led-matrix
apt-get -y remove bluez bluez-firmware pi-bluetooth triggerhappy

#Install pip requirements for scoreboard from the requirements.txt

pip3 install --upgrade pip
#pip3 install requests
#pip3 install regex
#pip3 install geocoder python_tsl2591 ephem
#pip3 uninstall -y numpy
#pip3 install env-canada==0.0.35
#pip3 install --upgrade pyowm
#pip3 install noaa_sdk fastjsonschema
#pip3 install apscheduler
#pip3 install lastversion
#pip3 install numpy
#pip3 install namespace

# Install pip requirements for nhl_setup
#pip3 install fastjsonschema
#pip3 install printtools
#pip3 install PyInstaller
#pip3 install questionary
#pip3 install regex


#Clone scoreboard repo
cd /home/pi
git clone https://github.com/riffnshred/nhl-led-scoreboard.git

cd nhl-led-scoreboard

#Install the python requirements from the requiremenst.txt file
pip3 install -r requirements.txt 

#Install rgb matrix
# Pull submodule and ignore changes from script
git submodule update --init --recursive
git config submodule.matrix.ignore all

cd submodules/matrix 

make build-python PYTHON=/usr/bin/python3
make install-python PYTHON=/usr/bin/python3
#cd bindings
#pip3 install -e python/

cd /home/pi
chown -R pi:pi nhl-led-scoreboard

EOF

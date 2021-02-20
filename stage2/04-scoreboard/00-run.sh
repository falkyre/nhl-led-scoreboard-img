#!/bin/bash -e
install -v -d ${ROOTFS_DIR}/home/pi/sbtools
install -v -d ${ROOTFS_DIR}/home/pi/.nhlledportal
install -v -d ${ROOTFS_DIR}/home/pi/.config/neofetch
install -v -d ${ROOTFS_DIR}/etc/cron.scoreboard
install -v -m 755 files/get_version ${ROOTFS_DIR}/etc/cron.scoreboard
install -v -m 755 files/led-image-viewer ${ROOTFS_DIR}/home/pi/sbtools
install -v -m 755 files/checkUpdate.sh ${ROOTFS_DIR}/home/pi/sbtools
install -v -m 755 files/issueUpload.sh ${ROOTFS_DIR}/home/pi/sbtools
install -v -m 755 files/changelog.sh ${ROOTFS_DIR}/home/pi/sbtools
install -v -m 755 files/sb-upgrade ${ROOTFS_DIR}/home/pi/sbtools
install -v -m 644 files/pi_crontab.txt ${ROOTFS_DIR}/home/pi/sbtools
install -v -m 644 files/runtext.py ${ROOTFS_DIR}/home/pi/sbtools
install -v -m 644 files/.bashrc ${ROOTFS_DIR}/home/pi/
install -v -m 644 files/.gitconfig ${ROOTFS_DIR}/home/pi/
install -v -m 755 files/sb-tools ${ROOTFS_DIR}/home/pi/sbtools
install -v -m 755 files/sb-help ${ROOTFS_DIR}/home/pi/sbtools
install -v -m 644 files/sb-help.txt ${ROOTFS_DIR}/home/pi/sbtools/
install -v -m 755 files/neofetch ${ROOTFS_DIR}/usr/bin/
install -v -m 664 files/neofetch_config.conf ${ROOTFS_DIR}/home/pi/.config/neofetch/config.conf
#Change the systemwide .bashrc by adding a bashrc.d in /etc
install -v -m 644 files/bash.bashrc ${ROOTFS_DIR}/etc/
install -v -d ${ROOTFS_DIR}/etc/bashrc.d
install -v -m 644 files/scoreboard.bash ${ROOTFS_DIR}/etc/bashrc.d
install -v -m 755 files/aptfile ${ROOTFS_DIR}/usr/local/bin
#Set up service file for autosetting timezone based on IP
install -v -m 755 files/autoset_tz.sh ${ROOTFS_DIR}/home/pi/sbtools
install -v -m 644 files/sb_autosettz.service "${ROOTFS_DIR}/etc/systemd/system/"
#Startup splash screen service
install -v -m 644 files/sb_splash.service "${ROOTFS_DIR}/etc/systemd/system/"
install -v -m 755 files/splash.gif ${ROOTFS_DIR}/home/pi/sbtools

#What repo to clone
REPO="https://github.com/riffnshred/nhl-led-scoreboard.git"
#REPO="https://github.com/falkyre/nhl-led-scoreboard.git"
#Checkout beta after clone? 1=yes, 0 = no
BETA=1
#What's the beta branch named if not beta?
BRANCH="beta"

on_chroot << EOF
#Remove packages that might impact performance as per https://github.com/hzeller/rpi-rgb-led-matrix
apt-get -y remove bluez bluez-firmware pi-bluetooth triggerhappy


python3 -m pip install --upgrade pip
python3 -m pip install archey4

#Clone scoreboard repo
cd /home/pi
rm -rf nhl-led-scoreboard
git clone --recursive ${REPO}

cd nhl-led-scoreboard
if [ "${BETA}" == "1" ]; then
   git checkout ${BRANCH}
fi

#Force pillow install to be 7.1.2 until requirements.txt is updated
python3 -m pip install pillow==7.1.2

#Install the python requirements from the requirements.txt file
python3 -m pip install -r requirements.txt 

#Install rgb matrix
# Pull submodule and ignore changes from script
git submodule update --init --recursive
git config submodule.matrix.ignore all

cd submodules/matrix 

make build-python PYTHON=/usr/bin/python3
make install-python PYTHON=/usr/bin/python3
#cd bindings
#pip3 install -e python/

mv bindings/python/samples/runtext.py bindings/python/samples/runtext.py.ori
mv /home/pi/sbtools/runtext.py bindings/python/samples/

#Build the utilities so we can use the led-image-viewer for a splash screen
#cd utils
#make 

#Install the python3-cairosvg
python3 -m pip uninstall cairosvg -y
apt-get -y install python3-cairosvg

cd /home/pi
chown -R pi:pi nhl-led-scoreboard

crontab -u pi /home/pi/sbtools/pi_crontab.txt

echo "# scoreboard version" >> /etc/crontab
echo "@reboot root run-parts /etc/cron.scoreboard/" >> /etc/crontab

#Set up for automatic timezone setup based on IP address
touch /home/pi/.nhlledportal/setTZ

systemctl unmask sb_autosettz.service
systemctl enable sb_autosettz.service

#Make user run sb-tools on first login
touch /home/pi/.nhlledportal/SETUP

#Splash screen service.  Will only work after user sets up scoreboard.conf
systemctl unmask sb_splash.service
systemctl enable sb_splash.service

#make the pi user the owner
chown -R pi:pi .config
chown pi:pi .bashrc
chown pi:pi .gitconfig
chown -R pi:pi .nhlledportal
chown -R pi:pi sbtools

EOF

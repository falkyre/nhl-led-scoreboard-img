#!/bin/bash -e
install -v -d ${ROOTFS_DIR}/home/pi/sbtools
install -v -d ${ROOTFS_DIR}/home/pi/.nhlupdate
install -v -d ${ROOTFS_DIR}/home/pi/.config/neofetch
install -v -d ${ROOTFS_DIR}/etc/cron.scoreboard
install -v -m 755 files/get_version ${ROOTFS_DIR}/etc/cron.scoreboard
install -v -m 755 files/checkUpdate.sh ${ROOTFS_DIR}/home/pi/sbtools
install -v -m 755 files/issueUpload.sh ${ROOTFS_DIR}/home/pi/sbtools
install -v -m 755 files/changelog.sh ${ROOTFS_DIR}/home/pi/sbtools
install -v -m 755 files/sb-upgrade ${ROOTFS_DIR}/home/pi/sbtools
install -v -m 644 files/pi_crontab.txt ${ROOTFS_DIR}/home/pi/sbtools
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

on_chroot << EOF
#Remove packages that might impact performance as per https://github.com/hzeller/rpi-rgb-led-matrix
apt-get -y remove bluez bluez-firmware pi-bluetooth triggerhappy


pip3 install --upgrade pip
pip3 install archey4

#Clone scoreboard repo
cd /home/pi
rm -rf nhl-led-scoreboard
git clone https://github.com/riffnshred/nhl-led-scoreboard.git

cd nhl-led-scoreboard

#Install the python requirements from the requirements.txt file
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


chown -R pi:pi .config
chown pi:pi .bashrc
chown pi:pi .gitconfig
chown -R pi:pi .nhlupdate
chown -R pi:pi sbtools

crontab -u pi /home/pi/sbtools/pi_crontab.txt

echo "# scoreboard version" >> /etc/crontab
echo "@reboot root run-parts /etc/cron.scoreboard/" >> /etc/crontab


EOF

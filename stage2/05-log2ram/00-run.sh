#!/bin/bash -e

on_chroot << EOF
if [ "${LOG2ZRAM}" = "1" ]; then
   # Install zram-config
   git clone --recurse-submodules https://github.com/ecdye/zram-config
   cd zram-config
   ./install.bash
else 
   #Install log2ram to have all /var/log files written to ram disk
   echo "deb http://packages.azlux.fr/debian/ buster main" | tee /etc/apt/sources.list.d/azlux.list
   wget -qO - https://azlux.fr/repo.gpg.key | apt-key add -
   apt update -y
   apt install log2ram -y
fi
EOF

install -v -m 644 files/log2ram.conf ${ROOTFS_DIR}/etc/

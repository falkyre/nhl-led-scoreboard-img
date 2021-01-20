#!/bin/bash -e

#Setup the supervisor daemon files
install -v -d ${ROOTFS_DIR}/etc/supervisor
install -v -m 644 files/supervisord.conf ${ROOTFS_DIR}/etc/supervisor
install -v -d ${ROOTFS_DIR}/etc/supervisor/conf.d
install -v -m 644 files/scoreboard.conf ${ROOTFS_DIR}/etc/supervisor/conf.d

install -v -m 644 files/supervisord.service                 "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
#Install supervisor
pip3 install supervisor

#Create systemd
systemctl unmask supervisord
systemctl enable supervisord 
systemctl disable supervisord

EOF

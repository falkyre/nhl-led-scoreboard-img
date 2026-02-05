#!/bin/bash -e

on_chroot << EOF
apt-get update
apt-get install -y ansible
EOF

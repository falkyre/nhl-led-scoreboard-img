#!/bin/bash -e

# Files in 'files/' directory of this stage are automatically copied to ROOTFS by pi-gen.
# We placed ansible files in 'files/tmp/ansible', so they are at '/tmp/ansible' inside the image.

on_chroot << EOF
cd /tmp/ansible
# Run playbook on localhost (chroot)
# We assume dependencies (ansible) were installed in previous step (00-install-ansible)
ansible-playbook setup-raspberry.yml -i "localhost," -c local -e "is_pigen_build=true"
EOF

# Cleanup
rm -rf "${ROOTFS_DIR}/tmp/ansible"

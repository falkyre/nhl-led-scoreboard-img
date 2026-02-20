# 1. DELETE the 'packer { required_plugins }' block completely.
# We will rely on the container's built-in ARM builder and the shell command.

variable "dietpi_url" {
  type    = string
  default = "https://dietpi.com/downloads/images/DietPi_RPi234-ARMv8-Trixie.img.xz"
}

variable "sb_img" {
  type    = string
  default = "dietpi-scoreboard"
}

source "arm" "dietpi" {
  file_checksum_url     = "https://dietpi.com/downloads/images/DietPi_RPi234-ARMv8-Trixie.img.xz.sha256"
  file_checksum_type    = "sha256"
  file_target_extension = "xz"
  file_unarchive_cmd    = ["xz", "--decompress", "$ARCHIVE_PATH"]
  file_urls             = ["${var.dietpi_url}"]
  
  image_build_method    = "resize" 
  image_chroot_env      = ["PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"]
  image_mount_path      = "/tmp/rpi_chroot"

  # PARTITION 1: BOOT
  image_partitions {
    name         = "boot"
    type         = "c"
    start_sector = "2048"
    filesystem   = "vfat"
    size         = "128M"
    mountpoint   = "/boot"
  }

  # PARTITION 2: ROOT
  image_partitions {
    name         = "root"
    type         = "83"
    start_sector = "264192"
    filesystem   = "ext4"
    size         = "0"
    mountpoint   = "/"
  }

  image_path                   = "${var.sb_img}.img"
  image_size                   = "3.5G"
  image_type                   = "dos"
  qemu_binary_destination_path = "/usr/bin/qemu-aarch64-static"
  qemu_binary_source_path      = "/usr/bin/qemu-aarch64-static"
}

build {
  sources = ["source.arm.dietpi"]

  # 1. Install Dependencies (Python + Ansible)
  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "apt-get update",
      "apt-get install -y python3 python3-apt ansible git libopenjp2-7"
    ]
  }

  # 2. Upload Ansible Files
  provisioner "file" {
    source      = "ansible/"
    destination = "/tmp/ansible"
  }

  # 3. Run Ansible via Shell (Bypasses Plugin Requirement)
  provisioner "shell" {
    inline = [
      # We run ansible-playbook directly inside the chroot.
      # -c local: Connect locally (since we are inside QEMU)
      # -i 'localhost,': Define ad-hoc inventory
      "ansible-playbook -i 'localhost,' -c local /tmp/ansible/setup-dietpi.yml -e 'ansible_python_interpreter=/usr/bin/python3'"
    ]
  }

  # 4. Cleanup
  provisioner "shell" {
    inline = [
      "apt-get remove -y --purge ansible git",
      "apt-get autoremove -y",
      "apt-get clean",
      "rm -rf /var/lib/apt/lists/* /tmp/ansible",
      "dd if=/dev/zero of=/zerofile bs=1M status=progress || true",
      "rm -f /zerofile"
    ]
  }

  post-processor "compress" {
    keep_input_artifact = true
    compression_level   = 9
    output              = "${var.sb_img}.img.xz"
  }
}
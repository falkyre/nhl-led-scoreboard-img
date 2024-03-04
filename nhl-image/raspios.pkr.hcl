# reuse this long string
variable "raspios_url" {
  type    = string
  #default = "https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2023-05-03/2023-05-03-raspios-bullseye-armhf-lite.img.xz"
  default = "https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2023-12-11/2023-12-11-raspios-bookworm-armhf-lite.img.xz"
}

variable "sb_img" {
  type = string
  default = "rpios-scoreboard"
}

source "arm" "pi" {
  file_checksum_type    = "sha256"
  file_checksum_url     = "${var.raspios_url}.sha256"
  file_target_extension = "xz"
  file_unarchive_cmd    = ["xz", "--decompress", "$ARCHIVE_PATH"]
  file_urls             = ["${var.raspios_url}"]
  image_build_method    = "resize"
  image_chroot_env      = ["PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"]
  image_mount_path      = "/tmp/rpi_chroot"
  image_partitions {
    filesystem   = "vfat"
    mountpoint   = "/boot"
    name         = "boot"
    size         = "256M"
    start_sector = "8192"
    type         = "c"
  }
  image_partitions {
    filesystem   = "ext4"
    mountpoint   = "/"
    name         = "root"
    size         = "0"
    start_sector = "532480"
    type         = "83"
  }
  image_path                   = "${var.sb_img}.img"
  image_size                   = "4G"
  image_type                   = "dos"
  qemu_binary_destination_path = "/usr/bin/qemu-arm-static"
  qemu_binary_source_path      = "/usr/bin/qemu-arm-static"
}

build {
  sources = ["source.arm.pi"]

  provisioner "ansible-local" {
    extra_arguments = [
     # "-vvv",
      "--connection=chroot",
      "-e ansible_host=/tmp/rpi_chroot"
      ]
    playbook_file   = "ansible/setup-raspberry.yml"
  }

  post-processor "compress" {
     keep_input_artifact = true
     compression_level = 9
     output = "${var.sb_img}.img.xz"
   }

}
  



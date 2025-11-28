# reuse this long string
variable "raspios_url" {
  type    = string
  default = "https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2025-11-24/2025-11-24-raspios-trixie-arm64-lite.img.xz"
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
  image_build_method    = "reuse"
  image_chroot_env      = ["PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"]
  image_mount_path      = "/tmp/rpi_chroot"
  image_partitions {
    filesystem   = "vfat"
    mountpoint   = "/boot"
    name         = "boot"
    size         = "512M"
    start_sector = "16384"
    type         = "c"
  }
  image_partitions {
    filesystem   = "ext4"
    mountpoint   = "/"
    name         = "root"
    size         = "6G"
    start_sector = "1064960"
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

  provisioner "ansible" {
    extra_arguments = [
     "-vvvvv",
      "--connection=chroot",
      "-e ansible_host=/tmp/rpi_chroot"
      ]
    playbook_file   = "ansible/setup-raspberry-trixie.yml"
  }

  post-processor "compress" {
     keep_input_artifact = true
     compression_level = 9
     output = "${var.sb_img}.img.xz"
   }

}
  

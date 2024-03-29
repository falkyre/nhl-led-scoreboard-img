"variables" = {}

"builders" = {
  "type" = "arm"

  "file_urls" = ["http://dl-cdn.alpinelinux.org/alpine/v3.12/releases/armhf/alpine-minirootfs-3.12.0-armhf.tar.gz"]

  "file_checksum_url" = "http://dl-cdn.alpinelinux.org/alpine/v3.12/releases/armhf/alpine-minirootfs-3.12.0-armhf.tar.gz.sha256"

  "file_checksum_type" = "sha256"

  "file_unarchive_cmd" = ["bsdtar", "-xpf", "$ARCHIVE_PATH", "-C", "$MOUNTPOINT"]

  "file_target_extension" = "tar.gz"

  "image_build_method" = "new"

  "image_path" = "alpine.img"

  "image_size" = "4G"

  "image_type" = "dos"

  "image_partitions" = {
    "name" = "root"

    "type" = "83"

    "start_sector" = "4096"

    "filesystem" = "ext4"

    "size" = "0"

    "mountpoint" = "/"
  }

  "qemu_binary_source_path" = "/usr/bin/qemu-arm-static"

  "qemu_binary_destination_path" = "/usr/bin/qemu-arm-static"

  "image_chroot_env" = ["PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/sbin:/usr/sbin"]
}

"provisioners" = {
  "type" = "shell"

  "inline" = ["echo 'nameserver 8.8.8.8' > /etc/resolv.conf", "apk update"]
}

"post-processors" = []
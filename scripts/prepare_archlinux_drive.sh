#/bin/bash

# Safe shell scripts, exit if error, unset variables, disable file expansion globbing (may break things), exit if any failure.
set -euf -o pipefail

echo "From: https://archlinuxarm.org/platforms/armv8/rockchip/rock64"
echo "Image: http://sg.mirror.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz"
echo "md5: http://sg.mirror.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz.md5"
echo "kernel modules: https://github.com/archlinuxarm/PKGBUILDs/tree/master/core/linux-aarch64-rc"

echo "Input drive to write to"
read -r drive

if [ "$drive" = "/dev/sda" ]; then 
	echo "Not writing to /dev/sda, exiting"
	exit 
fi

sudo dd if=/dev/zero "of=${drive}" bs=1M count=32

echo "
At the fdisk prompt, create the new partition:
Type o. This will clear out any partitions on the drive.
Type p to list partitions. There should be no partitions left.
Type n, then p for primary, 1 for the first partition on the drive, 32768 for the first sector, and then press ENTER to accept the default last sector.
Write the partition table and exit by typing w."
sudo fdisk "${drive}"

sudo mkfs.ext4 "${drive}1"
if [ ! -d root ]; then 
	mkdir root
fi
sudo mount "${drive}1" root

echo "Archlinux requires bsdtar version 3.3.0+, see here for installation: http://eyesfreelinux.ninja/posts/raspberry-pi-arch-and-the-fix.html"
/usr/local/bin/bsdtar --version
sudo /usr/local/bin/bsdtar -xpf ArchLinuxARM-aarch64-latest.tar.gz -C root
sudo cp boot.scr root/boot/boot.scr
sudo umount root
sudo dd if=idbloader.img "of=${drive}" seek=64 conv=notrunc
sudo dd if=uboot.img "of=${drive}" seek=16384 conv=notrunc
sudo dd if=trust.img "of=${drive}" seek=24576 conv=notrunc

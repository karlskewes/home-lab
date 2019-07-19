#/bin/bash

# Safe shell scripts, exit if error, unset variables, disable file expansion globbing (may break things), exit if any failure.
set -euf -o pipefail

mirror=http://sg.mirror.archlinuxarm.org/os
os_image=ArchLinuxARM-aarch64-latest.tar.gz
drive=""
working_dir="working_dir"


echo "From: https://archlinuxarm.org/platforms/armv8/rockchip/rock64"
echo "kernel modules: https://github.com/archlinuxarm/PKGBUILDs/tree/master/core/linux-aarch64-rc"

download_image() {
	if [[ -f "${os_image}" ]]; then
		echo "Image exists, overwrite? y/n"
		read -r response
		if [[ "$response" == "n" ]]; then
			return
		fi
	fi
	wget "${mirror}/${os_image}" -O "${os_image}"
	wget "${mirror}/${os_image}.md5" -O "${os_image}.md5"
	md5sum -c ${os_image}.md5
}

format_drive() {
	echo "Input drive to write to"
	read -r drive

	if [ "$drive" = "/dev/sda" ]; then
		echo "Not writing to /dev/sda, exiting"
		exit
	fi

	sudo dd if=/dev/zero "of=${drive}" bs=1M count=32

	echo "
	Due to potential data loss, interactive fdisk instructions below. At the prompt:
	1. 'o', clear any partitions on the drive.
	2. 'p', print partition table, should be none.
	3. 'n', new partition, 'p', primary, '1' first partition on drive, '32768' first sector offset, 'ENTER' default last sector.
	4. 'w', write the partition table and exit."
	sudo fdisk "${drive}"

	sudo mkfs.ext4 "${drive}1"
	mkdir -p root
}

write_os() {
	echo "Writing image to ${drive}"
	sudo mount "${drive}1" root

	echo "Archlinux requires bsdtar version 3.3.0+, see here for installation: http://eyesfreelinux.ninja/posts/raspberry-pi-arch-and-the-fix.html"
	/usr/local/bin/bsdtar --version
	sudo /usr/local/bin/bsdtar -xpf ${os_image} -C root
	sudo wget "${mirror}/rockchip/boot/rock64/boot.scr" -O root/boot/boot.scr
	sudo umount root

	wget "${mirror}/rockchip/boot/rock64/idbloader.img" -O idbloader.img
	wget "${mirror}/rockchip/boot/rock64/uboot.img" -O uboot.img
	wget "${mirror}/rockchip/boot/rock64/trust.img" -O trust.img

	sudo dd if=idbloader.img "of=${drive}" seek=64 conv=notrunc
	sudo dd if=uboot.img "of=${drive}" seek=16384 conv=notrunc
	sudo dd if=trust.img "of=${drive}" seek=24576 conv=notrunc
}

main () {
	mkdir -p "${working_dir}"
	cd "${working_dir}"
	download_image
	format_drive
	write_os
}

main "$@"

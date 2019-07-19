#/bin/bash

# Safe shell scripts, exit if error, unset variables, disable file expansion globbing (may break things), exit if any failure.
set -euf -o pipefail

update_uboot() {
	# Prepare boot.scr - install dependencies
	pacman-key --init
	pacman-key --populate archlinuxarm
	pacman --noconfirm -Sy uboot-rock64 uboot-tools


	if [[ ! $(mount | grep -q /dev/sda1) ]]; then
	  echo "Do you want to flash another drive? If not enter 'no' else enter drive: eg: /dev/mmcblk0 or /dev/sda"
	  read -r drive
	  if [[ "$drive" != "no" ]]; then
		dd if=/boot/idbloader.img "of=${drive}" seek=64 conv=notrunc
		dd if=/boot/uboot.img "of=${drive}" seek=16384 conv=notrunc
		dd if=/boot/trust.img "of=${drive}" seek=24576 conv=notrunc
	  fi
	fi
}

persist_mac() {
	# Set custom mac address and persist it.
	echo "Enter mac last two digits"
	read -r mac
	sed -i "s/macaddr .. .. .. .. .. ../macaddr da 19 c8 7a 6d $mac/" /boot/boot.txt
	cd /boot
	mv /boot/boot.scr /boot/boot.scr.old
	./mkscr

	echo "If mac address still changes on boot run:
	dd if=/dev/zero of=/dev/mtd3
	per: https://forum.pine64.org/showthread.php?tid=4972&page=2&highlight=%2Fdev%2Fmtd3"
}

main() {
	echo "This script needs to be run on Rock64, proceed? y/n"
	read -r proceed
	if [[ "$proceed" == 'n' ]]; then
		echo "Exiting"
		exit 1
	fi
	update_uboot
	persist_mac
}

main "$@"

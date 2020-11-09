#!/bin/bash

set -e

IMG=$1
NAME=$2
TEMPLATE=$3

LOOP=$(losetup -Pf ${IMG} --show)
trap cleanup EXIT
function cleanup {
	echo 'cleanup 1'
	losetup -d ${LOOP}
}

mount ${LOOP}p2 mnt/
mount ${LOOP}p1 mnt/boot
function cleanup {
	echo 'cleanup 2'
	umount mnt/boot
	umount mnt
	losetup -d ${LOOP}
}

mount -o bind,ro {,mnt}/etc/resolv.conf
mount --bind {,mnt}/dev
mount --bind {,mnt}/dev/pts
mount --bind {,mnt}/sys
mount --bind {,mnt}/proc
function cleanup {
	echo 'cleanup 3'
	umount mnt/{proc,sys,dev/pts,dev,etc/resolv.conf}
	umount mnt/boot
	umount mnt
	losetup -d ${LOOP}
}

cp -a {,mnt}/usr/bin/qemu-arm-static
function cleanup {
	echo 'cleanup 4'
	rm mnt/usr/bin/qemu-arm-static
	umount mnt/{proc,sys,dev/pts,dev,etc/resolv.conf}
	umount mnt/boot
	umount mnt
	losetup -d ${LOOP}
}

sed -i 's/^/#CHROOT /g' mnt/etc/ld.so.preload
function cleanup {
	echo 'cleanup 5'
	sed -i 's/#CHROOT //g' mnt/etc/ld.so.preload
	rm mnt/usr/bin/qemu-arm-static
	umount mnt/{proc,sys,dev/pts,dev,etc/resolv.conf}
	umount mnt/boot
	umount mnt
	losetup -d ${LOOP}
}

mkdir -p mnt/template mnt/common
function cleanup {
	echo 'cleanup 6'
	rmdir mnt/template mnt/common
	sed -i 's/#CHROOT //g' mnt/etc/ld.so.preload
	rm mnt/usr/bin/qemu-arm-static
	umount mnt/{proc,sys,dev/pts,dev,etc/resolv.conf}
	umount mnt/boot
	umount mnt
	losetup -d ${LOOP}
}

mount -o bind,ro ${TEMPLATE} mnt/template
function cleanup {
	echo 'cleanup 7'
	umount mnt/template
	rmdir mnt/template mnt/common
	sed -i 's/#CHROOT //g' mnt/etc/ld.so.preload
	rm mnt/usr/bin/qemu-arm-static
	umount mnt/{proc,sys,dev/pts,dev,etc/resolv.conf}
	umount mnt/boot
	umount mnt
	losetup -d ${LOOP}
}

mount -o bind,ro common mnt/common
function cleanup {
	echo 'cleanup 8'
	umount mnt/common
	umount mnt/template
	rmdir mnt/template mnt/common
	sed -i 's/#CHROOT //g' mnt/etc/ld.so.preload
	rm mnt/usr/bin/qemu-arm-static
	umount mnt/{proc,sys,dev/pts,dev,etc/resolv.conf}
	umount mnt/boot
	umount mnt
	losetup -d ${LOOP}
}

if [ -e $NAME.config ]; then
	touch mnt/config
	mount -o bind,ro $NAME.config mnt/config
	function cleanup {
		echo 'cleanup 9'
		umount mnt/config
		rm -f mnt/config
		umount mnt/common
		umount mnt/template
		rmdir mnt/template mnt/common
		sed -i 's/#CHROOT //g' mnt/etc/ld.so.preload
		rm mnt/usr/bin/qemu-arm-static
		umount mnt/{proc,sys,dev/pts,dev,etc/resolv.conf}
		umount mnt/boot
		umount mnt
		losetup -d ${LOOP}
	}
fi

echo Chrooting

chroot mnt /template/setup.sh

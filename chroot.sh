#!/bin/bash

IMG=$1

if [ -z "$IMG" ]; then
	exit
fi

set -e

trap cleanup EXIT

LOOP=$(losetup -Pf ${IMG} --show)
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

echo Chrooting

chroot mnt /bin/bash

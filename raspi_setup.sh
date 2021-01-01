#!/bin/bash

set -e

IMG=$1
NAME=$2
TEMPLATE=$3
EXTRA=$4
if [ "$EXTRA" == "" ]; then
	EXTRA=/dev/null
fi
MOUNTPOINT=mnt

LOOP=$(losetup -Pf ${IMG} --show)
trap cleanup EXIT
function cleanup {
	echo 'cleanup 1'
	losetup -d ${LOOP}
}

mount ${LOOP}p2 $MOUNTPOINT/
mount ${LOOP}p1 $MOUNTPOINT/boot
function cleanup {
	echo 'cleanup 2'
	umount $MOUNTPOINT/boot
	umount $MOUNTPOINT
	losetup -d ${LOOP}
}

mount -o bind,ro {,$MOUNTPOINT}/etc/resolv.conf
mount --bind {,$MOUNTPOINT}/dev
mount --bind {,$MOUNTPOINT}/dev/pts
mount --bind {,$MOUNTPOINT}/sys
mount --bind {,$MOUNTPOINT}/proc
function cleanup {
	echo 'cleanup 3'
	umount $MOUNTPOINT/{proc,sys,dev/pts,dev,etc/resolv.conf}
	umount $MOUNTPOINT/boot
	umount $MOUNTPOINT
	losetup -d ${LOOP}
}

cp -a {,$MOUNTPOINT}/usr/bin/qemu-arm-static
function cleanup {
	echo 'cleanup 4'
	rm $MOUNTPOINT/usr/bin/qemu-arm-static
	umount $MOUNTPOINT/{proc,sys,dev/pts,dev,etc/resolv.conf}
	umount $MOUNTPOINT/boot
	umount $MOUNTPOINT
	losetup -d ${LOOP}
}

FLAG_LD_SO_PRELOAD=0
if [ -e $MOUNTPOINT/etc/ld.so.preload ]; then
	sed -i 's/^/#CHROOT /g' $MOUNTPOINT/etc/ld.so.preload
	FLAG_LD_SO_PRELOAD=1
fi

function cleanup {
	echo 'cleanup 5'
	if [ $FLAG_LD_SO_PRELOAD -ne 0 ]; then
		sed -i 's/#CHROOT //g' $MOUNTPOINT/etc/ld.so.preload
	fi
	rm $MOUNTPOINT/usr/bin/qemu-arm-static
	umount $MOUNTPOINT/{proc,sys,dev/pts,dev,etc/resolv.conf}
	umount $MOUNTPOINT/boot
	umount $MOUNTPOINT
	losetup -d ${LOOP}
}

mkdir -p $MOUNTPOINT/template $MOUNTPOINT/common $MOUNTPOINT/extra
function cleanup {
	echo 'cleanup 6'
	rmdir $MOUNTPOINT/template $MOUNTPOINT/common $MOUNTPOINT/extra
	if [ $FLAG_LD_SO_PRELOAD -ne 0 ]; then
		sed -i 's/#CHROOT //g' $MOUNTPOINT/etc/ld.so.preload
	fi
	rm $MOUNTPOINT/usr/bin/qemu-arm-static
	umount $MOUNTPOINT/{proc,sys,dev/pts,dev,etc/resolv.conf}
	umount $MOUNTPOINT/boot
	umount $MOUNTPOINT
	losetup -d ${LOOP}
}

mount -o bind,ro ${TEMPLATE} $MOUNTPOINT/template
function cleanup {
	echo 'cleanup 7'
	umount $MOUNTPOINT/template
	rmdir $MOUNTPOINT/template $MOUNTPOINT/common $MOUNTPOINT/extra
	if [ $FLAG_LD_SO_PRELOAD -ne 0 ]; then
		sed -i 's/#CHROOT //g' $MOUNTPOINT/etc/ld.so.preload
	fi
	rm $MOUNTPOINT/usr/bin/qemu-arm-static
	umount $MOUNTPOINT/{proc,sys,dev/pts,dev,etc/resolv.conf}
	umount $MOUNTPOINT/boot
	umount $MOUNTPOINT
	losetup -d ${LOOP}
}

mount -o bind,ro common $MOUNTPOINT/common
function cleanup {
	echo 'cleanup 8'
	umount $MOUNTPOINT/common
	umount $MOUNTPOINT/template
	rmdir $MOUNTPOINT/template $MOUNTPOINT/common $MOUNTPOINT/extra
	if [ $FLAG_LD_SO_PRELOAD -ne 0 ]; then
		sed -i 's/#CHROOT //g' $MOUNTPOINT/etc/ld.so.preload
	fi
	rm $MOUNTPOINT/usr/bin/qemu-arm-static
	umount $MOUNTPOINT/{proc,sys,dev/pts,dev,etc/resolv.conf}
	umount $MOUNTPOINT/boot
	umount $MOUNTPOINT
	losetup -d ${LOOP}
}

if [ -e $NAME.config ]; then
	touch $MOUNTPOINT/config
	mount -o bind,ro $NAME.config $MOUNTPOINT/config
	function cleanup {
		echo 'cleanup 9'
		umount $MOUNTPOINT/config
		rm -f $MOUNTPOINT/config
		umount $MOUNTPOINT/common
		umount $MOUNTPOINT/template
		rmdir $MOUNTPOINT/template $MOUNTPOINT/common $MOUNTPOINT/extra
		if [ $FLAG_LD_SO_PRELOAD -ne 0 ]; then
			sed -i 's/#CHROOT //g' $MOUNTPOINT/etc/ld.so.preload
		fi
		rm $MOUNTPOINT/usr/bin/qemu-arm-static
		umount $MOUNTPOINT/{proc,sys,dev/pts,dev,etc/resolv.conf}
		umount $MOUNTPOINT/boot
		umount $MOUNTPOINT
		losetup -d ${LOOP}
	}
fi

if [ -d $EXTRA ]; then
	mount -o bind,ro ${EXTRA} $MOUNTPOINT/extra
	function cleanup {
		echo 'cleanup 10'
		umount $MOUNTPOINT/extra
		umount $MOUNTPOINT/config
		rm -f $MOUNTPOINT/config
		umount $MOUNTPOINT/common
		umount $MOUNTPOINT/template
		rmdir $MOUNTPOINT/template $MOUNTPOINT/common $MOUNTPOINT/extra
		if [ $FLAG_LD_SO_PRELOAD -ne 0 ]; then
			sed -i 's/#CHROOT //g' $MOUNTPOINT/etc/ld.so.preload
		fi
		rm $MOUNTPOINT/usr/bin/qemu-arm-static
		umount $MOUNTPOINT/{proc,sys,dev/pts,dev,etc/resolv.conf}
		umount $MOUNTPOINT/boot
		umount $MOUNTPOINT
		losetup -d ${LOOP}
	}
fi

echo Chrooting

chroot $MOUNTPOINT /template/setup.sh
# run extra setup
if [ -e $MOUNTPOINT/extra/setup.sh ]; then
	chroot $MOUNTPOINT /extra/setup.sh
fi

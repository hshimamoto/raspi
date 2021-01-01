#!/bin/bash

set -e

IMG=$1
NAME=$2
TEMPLATE=$3
EXTRA=$4
if [ "$EXTRA" == "" ]; then
	EXTRA=/dev/null
fi
MOUNTPOINT=mnt.$$

LOOP=$(losetup -Pf ${IMG} --show)
trap cleanup EXIT
function cleanup1 {
	echo 'cleanup 1'
	losetup -d ${LOOP}
}
function cleanup {
	cleanup1
}

mkdir -p $MOUNTPOINT
mount ${LOOP}p2 $MOUNTPOINT/
mount ${LOOP}p1 $MOUNTPOINT/boot
function cleanup2 {
	echo 'cleanup 2'
	umount $MOUNTPOINT/boot
	umount $MOUNTPOINT
	rmdir $MOUNTPOINT
}
function cleanup {
	cleanup2
	cleanup1
}

mount -o bind,ro {,$MOUNTPOINT}/etc/resolv.conf
mount --bind {,$MOUNTPOINT}/dev
mount --bind {,$MOUNTPOINT}/dev/pts
mount --bind {,$MOUNTPOINT}/sys
mount --bind {,$MOUNTPOINT}/proc
function cleanup3 {
	echo 'cleanup 3'
	umount $MOUNTPOINT/{proc,sys,dev/pts,dev,etc/resolv.conf}
}
function cleanup {
	cleanup3
	cleanup2
	cleanup1
}

cp -a {,$MOUNTPOINT}/usr/bin/qemu-arm-static
function cleanup4 {
	echo 'cleanup 4'
	rm $MOUNTPOINT/usr/bin/qemu-arm-static
}
function cleanup {
	cleanup4
	cleanup3
	cleanup2
	cleanup1
}

FLAG_LD_SO_PRELOAD=0
if [ -e $MOUNTPOINT/etc/ld.so.preload ]; then
	sed -i 's/^/#CHROOT /g' $MOUNTPOINT/etc/ld.so.preload
	FLAG_LD_SO_PRELOAD=1
fi

function cleanup5 {
	echo 'cleanup 5'
	if [ $FLAG_LD_SO_PRELOAD -ne 0 ]; then
		sed -i 's/#CHROOT //g' $MOUNTPOINT/etc/ld.so.preload
	fi
}
function cleanup {
	cleanup5
	cleanup4
	cleanup3
	cleanup2
	cleanup1
}

mkdir -p $MOUNTPOINT/template $MOUNTPOINT/common $MOUNTPOINT/extra
function cleanup6 {
	echo 'cleanup 6'
	rmdir $MOUNTPOINT/template $MOUNTPOINT/common $MOUNTPOINT/extra
}
function cleanup {
	cleanup6
	cleanup5
	cleanup4
	cleanup3
	cleanup2
	cleanup1
}

mount -o bind,ro ${TEMPLATE} $MOUNTPOINT/template
function cleanup7 {
	echo 'cleanup 7'
	umount $MOUNTPOINT/template
}
function cleanup {
	cleanup7
	cleanup6
	cleanup5
	cleanup4
	cleanup3
	cleanup2
	cleanup1
}

mount -o bind,ro common $MOUNTPOINT/common
function cleanup8 {
	echo 'cleanup 8'
	umount $MOUNTPOINT/common
}
function cleanup {
	cleanup8
	cleanup7
	cleanup6
	cleanup5
	cleanup4
	cleanup3
	cleanup2
	cleanup1
}

function cleanup9 {
	echo 'no cleanup 9'
}
if [ -e $NAME.config ]; then
	touch $MOUNTPOINT/config
	mount -o bind,ro $NAME.config $MOUNTPOINT/config
	function cleanup9 {
		echo 'cleanup 9'
		umount $MOUNTPOINT/config
	}
fi
function cleanup {
	cleanup9
	cleanup8
	cleanup7
	cleanup6
	cleanup5
	cleanup4
	cleanup3
	cleanup2
	cleanup1
}

function cleanup10 {
	echo 'no cleanup 10'
}
if [ -d $EXTRA ]; then
	mount -o bind,ro ${EXTRA} $MOUNTPOINT/extra
	function cleanup10 {
		echo 'cleanup 10'
		umount $MOUNTPOINT/extra
	}
fi
function cleanup {
	cleanup10
	cleanup9
	cleanup8
	cleanup7
	cleanup6
	cleanup5
	cleanup4
	cleanup3
	cleanup2
	cleanup1
}

echo Chrooting

chroot $MOUNTPOINT /template/setup.sh
# run extra setup
if [ -e $MOUNTPOINT/extra/setup.sh ]; then
	chroot $MOUNTPOINT /extra/setup.sh
fi

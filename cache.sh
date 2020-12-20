#!/bin/bash

if [ $# -lt 1 ]; then
	echo "cache.sh <arch> [base]"
	exit 1
fi

# set cleanup
trap cleanup EXIT
function cleanup {
	echo cleanup
}

RPI_Stamp=$(date +%Y%m%d)
RPI_Arch=$1
RPI_Extra=$2

case "$RPI_Arch" in
	armhf|arm64)
		;;
	*)
		echo "unknown arch $RPI_Arch"
		exit 1
esac

RPI_Base=-lite
case "$RPI_Extra" in
	desktop)
		RPI_Base=
		;;
esac

RPI_TemplateDir=templates/cache

if [ "$RPI_Arch" == "armhf" ]; then
	RPIOS=2020-12-02-raspios-buster-$RPI_Arch$RPI_Base
else
	RPIOS=2020-08-20-raspios-buster-$RPI_Arch$RPI_Base
fi
RPIOS_ZIP=images/$RPIOS.zip
RPIOS_IMG=$RPIOS.img

echo "START $(date)"

if [ -e $RPIOS_IMG ]; then
	echo "there is previous work"
	exit 1
fi

if [ ! -e $RPIOS_ZIP ]; then
	echo "no $RPIOS_ZIP"
	exit 1
fi

unzip $RPIOS_ZIP
if [ ! -e $RPIOS_IMG ]; then
	echo "no image found"
	exit 1
fi

RPI_Image=$RPI_Stamp-raspios-buster-$RPI_Arch$RPI_Base.img
mv $RPIOS_IMG $RPI_Image

echo "Increase image size $(date)"
./raspi_grow.sh $RPI_Image 200
echo "Resize image size $(date)"
sudo ./raspi_resize2fs.sh $RPI_Image
echo "Start setup with CHROOT $(date)"
sudo ./raspi_setup.sh $RPI_Image cache templates/cache $RPI_Arch

mv $RPI_Image caches/$RPI_Image

echo "END $(date)"

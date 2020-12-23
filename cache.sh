#!/bin/bash

if [ $# -lt 1 ]; then
	echo "cache.sh <arch> [base]"
	exit 1
fi

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
RPI_BaseSuffix=-lite
case "$RPI_Extra" in
	desktop)
		RPI_Base=
		RPI_BaseSuffix=-desktop
		;;
esac

RPI_TemplateDir=templates/cache

echo "START $(date)"

RPI_Image=$RPI_Stamp-raspios-buster-$RPI_Arch$RPI_Base.img

./extract.sh $RPI_Arch $RPI_BaseSuffix $RPI_Image
if [ ! -e $RPI_Image ]; then
	exit 1
fi

echo "Increase image size $(date)"
./raspi_grow.sh $RPI_Image 200
echo "Resize image size $(date)"
sudo ./raspi_resize2fs.sh $RPI_Image
echo "Start setup with CHROOT $(date)"
sudo ./raspi_setup.sh $RPI_Image cache templates/cache $RPI_Arch

mv $RPI_Image caches/$RPI_Image

echo "END $(date)"

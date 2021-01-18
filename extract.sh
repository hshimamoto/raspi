#!/bin/bash

if [ $# -lt 1 ]; then
	echo "extract.sh <arch> <base suffix> <outfile>"
	exit 1
fi

RPI_Arch=$1
RPI_Extra=$2
RPI_Image=$3

case "$RPI_Arch" in
	armhf|arm64)
		;;
	*)
		echo "unknown arch $RPI_Arch"
		exit 1
esac

RPI_Base=
case "$RPI_Extra" in
	-lite)
		RPI_Base=-lite
		;;
	-desktop)
		;;
	*)
		echo "unknown base"
		exit 1
		;;
esac

if [ "$RPI_Arch" == "armhf" ]; then
	RPIOS=2021-01-11-raspios-buster-$RPI_Arch$RPI_Base
else
	RPIOS=2020-08-20-raspios-buster-$RPI_Arch$RPI_Base
fi
RPIOS_ZIP=images/$RPIOS.zip
RPIOS_IMG=$RPIOS.img

echo "extract: START $(date)"

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

mv $RPIOS_IMG $RPI_Image

echo "extract: END $(date)"

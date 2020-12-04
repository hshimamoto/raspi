#!/bin/bash

if [ $# -lt 2 ]; then
	echo "setup.sh <hostname> <template> <arch> [base] [config]"
	exit 1
fi

# set cleanup
trap cleanup EXIT
function cleanup {
	echo cleanup
}

RPI_Stamp=$(date +%Y%m%d)
RPI_Host=$1
RPI_Template=$2
RPI_Arch=$3
RPI_ExtraConfig=$4
RPI_Config=$RPI_Host.config

case "$RPI_Arch" in
	armhf|arm64)
		;;
	*)
		echo "unknown arch $RPI_Arch"
		exit 1
esac

RPI_Base=-lite
case "$RPI_ExtraConfig" in
	desktop)
		RPI_Base=
		RPI_ExtraConfig=$5
		;;
esac

# generate config
if [ -e $RPI_Config ]; then
	echo "unable to create config"
	exit 1
fi
if [ -n "$RPI_ExtraConfig" ]; then
	if [ -e $RPI_ExtraConfig ]; then
		cp $RPI_ExtraConfig $RPI_Config
	fi
fi
cat <<_EOF_ >> $RPI_Config
NAME=$RPI_Host
_EOF_
function cleanup {
	echo cleanup
	rm -f $RPI_Config
}

RPI_TemplateDir=templates/$RPI_Template
if [ ! -d $RPI_TemplateDir ]; then
	echo "no template $RPI_Template"
	exit 1
fi

# precheck
if [ -x $RPI_TemplateDir/precheck.sh ]; then
	$RPI_TemplateDir/precheck.sh $RPI_Config
	if [ $? -ne 0 ]; then
		echo "precheck failed"
		exit 1
	fi
fi

RPIOS=2020-08-20-raspios-buster-$RPI_Arch$RPI_Base
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

RPI_Image=$RPI_Stamp-$RPI_Host-raspios-buster-$RPI_Arch$RPI_Base-$RPI_Template.img
mv $RPIOS_IMG $RPI_Image

echo "Increase image size $(date)"
./raspi_grow.sh $RPI_Image 200
echo "Resize image size $(date)"
sudo ./raspi_resize2fs.sh $RPI_Image
echo "Start setup with CHROOT $(date)"
sudo ./raspi_setup.sh $RPI_Image $RPI_Host $RPI_TemplateDir $RPI_Arch

echo "END $(date)"

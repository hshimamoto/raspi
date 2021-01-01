#!/bin/bash

if [ $# -lt 2 ]; then
	echo "setup.sh <hostname> <template> <arch> [base] [config] [extra]"
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
RPI_ExtraDir=$5
RPI_Config=$RPI_Host.config

case "$RPI_Arch" in
	armhf|arm64)
		;;
	*)
		echo "unknown arch $RPI_Arch"
		exit 1
esac

RPI_Base=-lite
RPI_CacheOpt=
case "$RPI_ExtraConfig" in
	desktop)
		RPI_Base=
		RPI_CacheOpt=desktop
		RPI_ExtraConfig=$5
		;;
esac

if [ -d "$RPI_ExtraConfig" ]; then
	#swap
	RPI_ExtraConfig_tmp=$RPI_ExtraDir
	RPI_ExtraDir=$RPI_ExtraConfig
	RPI_ExtraConfig=$RPI_ExtraConfig_tmp
fi

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
Template=$RPI_Template
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
if [ -x $RPI_ExtraDir/precheck.sh ]; then
	$RPI_ExtraDir/precheck.sh $RPI_Config
	if [ $? -ne 0 ]; then
		echo "precheck failed"
		exit 1
	fi
fi

if [ "$RPI_Arch" == "armhf" ]; then
	RPIOS=2020-12-02-raspios-buster-$RPI_Arch$RPI_Base
else
	RPIOS=2020-08-20-raspios-buster-$RPI_Arch$RPI_Base
fi

echo "START $(date)"

# is there any cache?

if [ ! -d caches ]; then mkdir caches; fi
CACHE_IMG=`ls caches/*-raspios-buster-$RPI_Arch$RPI_Base.img | sort | tail -n 1`
if [ "$CACHE_IMG" == "" ]; then
	echo "Generate cache"
	./cache.sh $RPI_Arch $RPI_CacheOpt
fi
CACHE_IMG=`ls caches/*-raspios-buster-$RPI_Arch$RPI_Base.img | sort | tail -n 1`
if [ "$CACHE_IMG" == "" ]; then
	echo "No cache image found"
	exit 1
fi

RPI_Image=$RPI_Stamp-$RPI_Host-raspios-buster-$RPI_Arch$RPI_Base-$RPI_Template.img
cp $CACHE_IMG $RPI_Image

if [ -e $RPI_TemplateDir/imagesize ]; then
	imagesize=$(cat $RPI_TemplateDir/imagesize)
	echo "Need more space $imagesize"
	echo "Increase image size $(date)"
	./raspi_grow.sh $RPI_Image $imagesize
	echo "Resize image size $(date)"
	sudo ./raspi_resize2fs.sh $RPI_Image
fi
if [ -e $RPI_ExtraDir/imagesize ]; then
	imagesize=$(cat $RPI_ExtraDir/imagesize)
	echo "Need more space $imagesize"
	echo "Increase image size $(date)"
	./raspi_grow.sh $RPI_Image $imagesize
	echo "Resize image size $(date)"
	sudo ./raspi_resize2fs.sh $RPI_Image
fi

echo "Start setup with CHROOT $(date)"
sudo ./raspi_setup.sh $RPI_Image $RPI_Host $RPI_TemplateDir $RPI_ExtraDir

echo "END $(date)"

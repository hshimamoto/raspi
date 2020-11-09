#!/bin/bash

set -e

RPI_Config=$1
# load config
. $RPI_Config

if [ "$NAME" == "" ]; then
	exit 1
fi
if [ "$WIFIAP_SSID" == "" ]; then
	exit 1
fi
if [ "$WIFIAP_PASS" == "" ]; then
	exit 1
fi

exit 0

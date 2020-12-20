#!/bin/bash

priority=$1
ssid=$2
pass=$3

if [ "$pass" == "" ]; then
	exit 0
fi

echo "Setup wpa_supplicant for $ssid"
wpa_passphrase $ssid $pass | sed -e "s/#.\+/priority=$priority/" >> /etc/wpa_supplicant/wpa_supplicant.conf

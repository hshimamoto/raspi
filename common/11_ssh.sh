#!/bin/bash

echo "Enabling SSH"

touch /boot/ssh

. /config

if [ "$PASSWD" == "" ]; then
	echo "no passwd update"
	exit
fi

echo "pi:$PASSWD" | chpasswd

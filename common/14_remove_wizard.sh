#!/bin/bash

echo "Removing wizard"

if [ -e /etc/xdg/autostart/piwiz.desktop ]; then
	rm -f /etc/xdg/autostart/piwiz.desktop
fi

systemctl disable userconfig
systemctl enable getty@tty1

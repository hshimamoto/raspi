#!/bin/bash

echo "Start setup in CHROOT"
echo "TEMPLATE: esp (with home Wi-Fi)"

if [ -e /config ]; then
	. /config
fi

echo "NAME: $NAME"

# non interactive
export DEBIAN_FRONTEND=noninteractive

/common/01_package_update.sh
/common/02_essential_package.sh
/common/10_hostname.sh $NAME
/common/11_ssh.sh
/common/12_hdmi.sh
/common/13_wifi.sh
/common/14_remove_wizard.sh
/common/15_timezone.sh
/common/20_wpa_supplicant.sh

# install python
/common/30_pkg_install.sh python3 python3-pip python3-venv

# install esptool
pip3 install esptool

/common/99_cleanup.sh

echo "End"

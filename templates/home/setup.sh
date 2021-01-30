#!/bin/bash

echo "Start setup in CHROOT"
echo "TEMPLATE: home"

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

/common/99_cleanup.sh

echo "End"

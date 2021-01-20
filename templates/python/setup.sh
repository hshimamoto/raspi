#!/bin/bash

echo "Start setup in CHROOT"
echo "TEMPLATE: python"

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

# install python
/common/30_pkg_install.sh python3 python3-pip

/common/99_cleanup.sh

echo "End"

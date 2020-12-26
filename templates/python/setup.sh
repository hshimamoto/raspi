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

# install python
apt-get install -y python3 python3-pip

/common/99_cleanup.sh

echo "End"

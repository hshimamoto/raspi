#!/bin/bash

echo "Start setup in CHROOT"
echo "TEMPLATE: cache"

# non interactive
export DEBIAN_FRONTEND=noninteractive

/common/01_package_update.sh
/common/02_essential_package.sh

/common/99_cleanup.sh

echo "End"

#!/bin/bash

# rfkill service stops wifi on default
# enable wifi
cd /var/lib/systemd/rfkill
find . -type f | while read f; do
	echo 0 > $f
done

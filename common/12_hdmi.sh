#!/bin/bash

sed -i \
	-e 's/#disable_overscan=1/disable_overscan=1/' \
	-e 's/#hdmi_force_hotplug=1/hdmi_force_hotplug=1/' \
	/boot/config.txt

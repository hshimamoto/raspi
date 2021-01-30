#!/bin/bash

echo "Set timezone Asia/Tokyo"

ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

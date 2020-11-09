#!/bin/bash

# non interactive
export DEBIAN_FRONTEND=noninteractive

# cleaning up
apt-get clean

# zero fill
dd if=/dev/zero of=dummy bs=1M
rm -f dummy

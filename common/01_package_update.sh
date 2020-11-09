#!/bin/bash

# non interactive
export DEBIAN_FRONTEND=noninteractive

# update packages
apt-get update
apt-get dist-upgrade -y

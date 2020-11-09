#!/bin/bash

NAME=$1

echo $NAME > /etc/hostname
sed -ie "s/raspberrypi/$NAME/g" /etc/hosts

#!/bin/bash

# run as root

set -e

IMG=$1

LOOP=$(losetup -Pf ${IMG} --show)

trap 'echo Cleaning up...; cleanup' EXIT
function cleanup {
	losetup -d ${LOOP}
}

e2fsck -f ${LOOP}p2
resize2fs -f ${LOOP}p2
e2fsck -f ${LOOP}p2

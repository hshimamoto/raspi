#!/bin/bash

set -e

IMG=$1
MEGA=${2:-100}

# create a dummy
fdisk ${IMG} << EOF > /dev/null
n




w
EOF

# expected partition
# dummy p3
# boot p1
# root p2

dd if=/dev/zero bs=1M count=${MEGA} >> ${IMG}

# grow partition and remove dummy
fdisk ${IMG} << EOF > /dev/null
d
2
n
p



d

w
EOF

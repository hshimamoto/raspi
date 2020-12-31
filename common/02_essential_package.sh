#!/bin/bash

# non interactive
export DEBIAN_FRONTEND=noninteractive

exit_code=1
while [ $exit_code -ne 0 ]; do
	apt-get install -y vim screen git
	exit_code=$?
done

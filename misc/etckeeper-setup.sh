#!/bin/bash

# Copyright © Jonathan G. Rennison 2014 <j.g.rennison@gmail.com>
# License: New BSD License, see BSD-LICENSE.txt

# This installs etckeeper and git if not already installed (assumes debian-like system)
# This sets the VCS used to git, and inits/commits the repo if not already

which etckeeper &> /dev/null && which git &> /dev/null || apt-get -y install etckeeper git-core

if [ '!' -w "/etc/etckeeper/etckeeper.conf" ]; then
	echo "Can't write to /etc/etckeeper/etckeeper.conf, maybe try as root? Aborting" >&2
	exit 1
fi

sed -i -e 's/^[[:space:]]*VCS=/#VCS=/g' "/etc/etckeeper/etckeeper.conf"
sed -i -e 's/[[:space:]]*#[[:space:]]*VCS="git"/VCS="git"/g' "/etc/etckeeper/etckeeper.conf"

etckeeper init
etckeeper commit "Initial Commit"

#!/bin/bash

# Copyright © Jonathan G. Rennison 2014 <j.g.rennison@gmail.com>
# License: New BSD License, see BSD-LICENSE.txt

# This installs a sysctl setting for kernel.core_pattern, /proc/sys/kernel/core_pattern into /etc/sysctl.d/60-core.conf

TARG="/etc/sysctl.d/60-core.conf"

mkdir -p /tmp/cores
chmod a+rwx /tmp/cores

if [ "$?" -ne 0 ]; then
        echo "Can't chmod /tmp/cores, maybe try as root? Aborting" >&2
        exit 1
fi

cat > "$TARG" << EOL
# This file was created by `readlink -f "$0"` at `date "+%F %T %z"`

kernel.core_pattern=/tmp/core.%e.%t.%p
EOL

if [ "$?" -ne 0 ]; then
	echo "Can't write to $TARG, maybe try as root? Aborting" >&2
	exit 1
fi

service procps start

#!/bin/bash

# Copyright © Jonathan G. Rennison 2014 <j.g.rennison@gmail.com>
# License: New BSD License, see BSD-LICENSE.txt

# This script enables password-less sudo access for the following commands for the current login user:
CMDLIST=(
	'/usr/bin/apt-get update'
	'/usr/bin/apt-get upgrade'
)
# This creates the file /etc/sudoers.d/nopw-USERNAME
# This assumes that a suitable includedir directive is already in /etc/sudoers

. "`dirname "$0"`/../common/util.sh"

sudoers_add_prechecks

sudoers_add_tmps "nopw-$USER"

cat > "$TMPSUDOERS" << EOL
# This file was created by `readlink -f "$0"` at `date "+%F %T %z"`

EOL

for cmd in "${CMDLIST[@]}"; do
	echo "$USER ALL  = NOPASSWD: $cmd" >> "$TMPSUDOERS"
done

sudoers_add_install

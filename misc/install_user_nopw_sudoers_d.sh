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

USER="`logname`"
USERUID="`id -u "$USER"`"
CURUID="`id -u`"

if [ "$CURUID" -ne 0 ]; then
	echo "You are not currently root, aborting"
	exit 1
fi

if [ -z "$USER" -o -z "$USERUID" ]; then
	echo "Cannot determine non-root user name/ID"
	exit 1
fi

if [ "$USERUID" -eq 0 ]; then
	echo "Cannot determine non-root user name/ID"
	exit 1
fi

SUDOERS="/etc/sudoers.d/nopw-$USER"

TMPSUDOERS="`mktemp -t "sudoers-nopw-$USER-XXXXXXXXXXXXXXXXXXXXX"`"

function finish {
	rm "$TMPSUDOERS"
}
trap finish EXIT

cat > "$TMPSUDOERS" << EOL
# This file was created by `readlink -f "$0"` at `date "+%F %T %z"`

EOL

for cmd in "${CMDLIST[@]}"; do
	echo "$USER ALL  = NOPASSWD: $cmd" >> "$TMPSUDOERS"
done

visudo -c -f "$TMPSUDOERS" || { echo "visudo validation failed"; exit 1; }

echo "This will install the following file to $SUDOERS"
echo ""
cat "$TMPSUDOERS"

echo -e '\n\n** Do not run this script unless you are categorically sure that you know what you are doing **'
echo "Type 'y' or 'yes' to continue and install"
read -p "" -r
if [ "$REPLY" != "y" -a "$REPLY" != "yes" ]; then
	echo "Aborting"
	exit 1
fi

install -m 0440 -o root -g root "$TMPSUDOERS" "$SUDOERS"

sudo -u "$USER" sudo -l || { echo "'sudo -l' failed, reverting change"; rm "$SUDOERS"; exit 1; }

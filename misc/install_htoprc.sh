#!/bin/bash

# Copyright © Jonathan G. Rennison 2014 <j.g.rennison@gmail.com>
# License: New BSD License, see BSD-LICENSE.txt

# This installs the associated copy of htoprc in ~/.config/htop/htoprc
# This is not done by default a some machines have a customised htoprc

THISDIR="$(readlink -f $(dirname "$0"))"

mkdir -p "$HOME/.config/htop/"
HTOPRC="$HOME/.config/htop/htoprc"
BCKUP="$HOME/.config/htop/htoprc-`date -u "+%Y%m%dT%H%M%SZ"`"
SRC="$THISDIR/htoprc"

if [ -e "$HTOPRC" -o -L "$HTOPRC" ]; then
	echo "Backing up old htoprc to $BCKUP"
	mv "$HTOPRC" "$BCKUP"
fi

echo "Installing new htoprc"
cp "$THISDIR/htoprc" "$HOME/.config/htop/htoprc"

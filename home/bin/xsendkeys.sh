#!/bin/bash

# Copyright © Jonathan G. Rennison 2014 <j.g.rennison@gmail.com>
# License: New BSD License, see BSD-LICENSE.txt

# This is intended for programmatic insertion of text in $1 into the current X window
# for example by binding to a global hotkey
# NB: this currently requires that the mouse is in vaguely the right place, as middle-click insertion is used

OLDSEL="`xclip -o < /dev/null`"
echo -n "$1" | xclip -i
xdotool click 2 < /dev/null
echo -n "$OLDSEL" | xclip -i

#!/bin/bash

# Copyright © Jonathan G. Rennison 2014 <j.g.rennison@gmail.com>
# License: New BSD License, see BSD-LICENSE.txt

# This uses less if the input is more than one page
# Otherwise cat is used
# This is not the same as less -RSXF, as that leaves the last page on screen when terminating in multi-page mode

text=$(</dev/stdin)

lines=$(wc -l <<< "$text")

if (( lines > `tput lines` - 1 )); then
	less -R -S -+X -+F +g <<< "$text"
else
	cat <<< "$text"
fi

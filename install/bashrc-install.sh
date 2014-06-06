#!/bin/bash

# Copyright © Jonathan G. Rennison 2014 <j.g.rennison@gmail.com>
# License: New BSD License, see BSD-LICENSE.txt

# DESCRIPTION: Install links to .bashrc_ext and .bash_aliases into .bashrc if not already present

. "`dirname "$0"`/../common/util.sh"

display_description_line "$0"


read -d '' inserttxt << EOL

if [ -f ~/.bashrc_ext ]; then
	. ~/.bashrc_ext
fi
EOL

check_update_file '\.bashrc_ext' "$inserttxt" "$HOME/.bashrc" ".bashrc_ext include"


read -d '' inserttxt << EOL

if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi
EOL

check_update_file '\.bash_aliases' "$inserttxt" "$HOME/.bashrc" ".bash_aliases include"

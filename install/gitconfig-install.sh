#!/bin/bash

# Copyright © Jonathan G. Rennison 2014 <j.g.rennison@gmail.com>
# License: New BSD License, see BSD-LICENSE.txt

# DESCRIPTION: Install link to .gitconfig_ext into .gitconfig if not already present

. "`dirname "$0"`/../common/util.sh"

display_description_line "$0"


read -d '' inserttxt << EOL

[include]
	path = .gitconfig_ext
EOL

check_update_file 'path = \.gitconfig_ext' "$inserttxt" "$HOME/.gitconfig" "Git config include"

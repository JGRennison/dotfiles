#!/bin/bash

# Copyright © Jonathan G. Rennison 2014 <j.g.rennison@gmail.com>
# License: New BSD License, see BSD-LICENSE.txt

# Args: grep_string insert_string file_name msg_text
function check_update_file() {
	if grep -q "$1" "$3" &> /dev/null; then
		echo ".	$4 already installed" >&2
	else
		cat >> "$3" <<< "$2"

		if [ $? -eq 0 ]; then
			echo "+	$4 successfully installed" >&2
		fi
	fi
}

# Args: filename
function display_description_line() {
	printf "%-30s %s\n" "`basename "$1"`" "`sed -n -e "/^# DESCRIPTION: / { s/^# DESCRIPTION: //; p }" < "$1"`"
}

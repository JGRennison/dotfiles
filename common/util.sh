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

function sudoers_add_prechecks() {
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
}

# Args: file base name
function sudoers_add_tmps() {
	SUDOERS="/etc/sudoers.d/$1"
	TMPSUDOERS="`mktemp -t "sudoers-$1-XXXXXXXXXXXXXXXXXXXXX"`"

	function finish {
		rm "$TMPSUDOERS"
	}
	trap finish EXIT
}

function sudoers_add_install() {
	visudo -c -f "$TMPSUDOERS" || { echo "visudo validation failed"; exit 1; }

	echo "This will install the following file to $SUDOERS"
	echo "`tput setaf 6`"
	cat "$TMPSUDOERS"
	echo "`tput sgr0`"

	echo '** Do not run this script unless you are categorically sure that you know what you are doing **'
	echo "Type 'y' or 'yes' to continue and install"
	read -p "" -r
	if [ "$REPLY" != "y" -a "$REPLY" != "yes" ]; then
		echo "Aborting"
		exit 1
	fi

	install -m 0440 -o root -g root "$TMPSUDOERS" "$SUDOERS"

	echo ""
	echo "sudo -l:"
	sudo -u "$USER" sudo -l || { echo "'sudo -l' failed, reverting change"; rm "$SUDOERS"; exit 1; }
}

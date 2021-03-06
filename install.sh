#!/bin/bash

############################################################################
# FILE:                install.sh                                          #
# DESCRIPTION:         Installs symlinks to dotfiles in $HOME              #
# AUTHOR:              Jonathan G. Rennison <j.g.rennison@gmail.com>       #
# LICENSE:             New BSD License, see BSD-LICENSE.txt                #
#                                                                          #
# Copyright © Jonathan G. Rennison 2014                                    #
############################################################################

NOWARN=0
NOBACKUP=0
DRYRUN=0
JUSTDOIT=0

THISDIR="$(readlink -f $(dirname "$0"))"
. "$THISDIR/common/util.sh"

function show_help() {
	echo "Installs symlinks to dotfiles in $THISDIR/home/ into $HOME/" >&2
	echo "Usage: install.sh [options]" >&2
	echo "-q: Quiet mode, do not prompt on startup" >&2
	echo "-n: Do not backup existing files which are being replaced" >&2
	echo "-y: Do not prompt when replacing existing files" >&2
	echo "-d: Do a dry run" >&2
	echo "-h: Show this help" >&2
}

while getopts ":qndyh" opt; do
	case $opt in
		q)
			NOWARN=1
			;;
		n)
			NOBACKUP=1
			;;
		d)
			DRYRUN=1
			;;
		y)
			JUSTDOIT=1
			;;
		h | \?)
			show_help
			exit 1
			;;
	esac
done

if [ "$DRYRUN" != 0 ]; then
	echo "DRY RUN"
elif [ "$NOWARN" == 0 ]; then
	echo "About to install symlinks to the following files in $HOME/"
	find "$THISDIR/home" -mindepth 1 '!' -type d -printf '\t%P\n'
	echo "About to execute install scripts"
	while read -d $'\0' line ; do
		printf "\t%-30s %s\n" "$line" "`sed -n -e "/^# DESCRIPTION: / { s/^# DESCRIPTION: //; p }" < "$THISDIR/install/$line"`"
	done < <( find "$THISDIR/install" -mindepth 1 '!' -type d -printf '%P\0' )
	echo "Type 'y' or 'yes' to continue and install"
	echo "Type 'd' or 'dry' for a dry-run"
	echo "Type 'h' or 'help' to show the help text"
	read -p "" -r
	if [ "$REPLY" == "d" -o "$REPLY" == "dry" ]; then
		DRYRUN=1
		echo "DRY RUN"
	elif [ "$REPLY" == "h" -o "$REPLY" == "help" ]; then
		show_help
		exit 1
	elif [ "$REPLY" != "y" -a "$REPLY" != "yes" ]; then
		echo "Aborting"
		exit 1
	fi
fi

if [ "$DRYRUN" == 0 ]; then
	pushd "$THISDIR" &> /dev/null
	git submodule update --init --recursive
	popd &> /dev/null
fi

BACKUPDIR="$HOME/old_dotfiles_`date -u "+%Y%m%dT%H%M%SZ"`"

LNOPTS=`ln --help | grep -e "--relative" -q && echo "-r"`

# Keep a copy of STDIN
exec 3<&0

while read -d $'\0' line ; do
	SRC="$THISDIR/home/$line"
	TARGET="$HOME/$line"
	TARGETDISP="$line"

	if [ -L "$TARGET" -a "`readlink -f "$SRC"`" == "`readlink -f "$TARGET"`" ]; then
		print_status_line "." "Already installed" "$TARGETDISP"
		continue
	elif [ -e "$TARGET" -a ! -L "$TARGET" ]; then
		print_status_line "!" "Already exists" "$TARGETDISP"

		if [ "$DRYRUN" != 0 ]; then
			continue;
		fi

		if [ "$NOBACKUP" == 0 ]; then
			MSG="Type 'y' or 'yes' to backup original $TARGETDISP to ${BACKUPDIR#$HOME/}/$line and install new one"
		else
			MSG="Type 'y' or 'yes' to DELETE original $TARGETDISP and install new one"
		fi

		if [ "$JUSTDOIT" == 0 ]; then
			echo "$MSG"
			read -p "" -r <&3
			if [ "$REPLY" != "y" -a "$REPLY" != "yes" ]; then
				print_status_line "!" "Not installed" "$TARGETDISP"
				continue
			fi
		fi

		if [ "$NOBACKUP" == 0 ]; then
			print_status_line "b" "Backing up" "$TARGETDISP to ${BACKUPDIR#$HOME/}/$line"
			mkdir -p "`dirname "$BACKUPDIR/$line"`"
			mv "$TARGET" "$BACKUPDIR/$line"
		else
			print_status_line "-" "Deleting" "$TARGETDISP"
			rm "$TARGET"
		fi
	elif [ "$DRYRUN" != 0 ]; then
		print_status_line "+" "Would install" "$TARGETDISP"
		continue
	elif [ -L "$TARGET" ]; then
		print_status_line "-" "Removing old symlink" "$TARGETDISP"
		rm "$TARGET"
	fi

	print_status_line "+" "Installing" "$TARGETDISP"
	mkdir -p "`dirname "$TARGET"`"
	ln -s $LNOPTS "$SRC" "$TARGET"
done < <(find "$THISDIR/home" -mindepth 1 '!' -type d -printf '%P\0' )

while read -d $'\0' line ; do
	if [ "$DRYRUN" != 0 ]; then
		DRYRUN=1 "$THISDIR/install/$line"
	else
		"$THISDIR/install/$line"
	fi
done < <( find "$THISDIR/install" -mindepth 1 '!' -type d -printf '%P\0' )

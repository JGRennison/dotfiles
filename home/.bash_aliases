# Copyright © Jonathan G. Rennison 2014 <j.g.rennison@gmail.com>
# License: New BSD License, see BSD-LICENSE.txt

alias ls='ls -h --classify --color=auto'
alias gitka='gitk --all'
alias gg='git gui'
alias hv='history | less +G'
alias dmt='dmesg -T | tail'
alias dml='dmesg -T | less +G'
alias umount_gvfs_smb='gvfs-mount -s smb'
alias newpty='script -q /dev/null'
alias loadalias='. ~/.bash_aliases'
alias openports='netstat -tulanpW'

alias sshfst='sshfs -o idmap=user -o transform_symlinks -o ControlPath=none'

function sshfsa() {
	mkdir -p ~/mnt/"$1"
	sshfst "$1":/ ~/mnt/"$1"
}

# function to do `cd` using `xd`
function cxd() {
	cd `xd "$@"`
}

# function to do `pushd` using `xd`
function pxd() {
	pushd `xd "$@"`
}

# Wait until pgrep returns no results
function pgrepwait() {
	while pgrep "$@" > /dev/null; do sleep 1; done
}

# Based on from http://tychoish.com/rhizome/9-awesome-ssh-tricks/
# This works even if the SSH agent has no identities currently loaded
function ssh-reagent() {
	for agent in /tmp/ssh-*/agent.*; do
		export SSH_AUTH_SOCK="$agent"
		ssh-add -l &> /dev/null
		if [ "$?" -lt 2 ]; then
			echo "Found working SSH Agent"
			ssh-add -l
			return
		fi
	done
	echo "Cannot find SSH agent"
}

function dump_args() {
	for a in "$@"; do
		printf '\"%q\"\n' "$a"
	done
}

function mcd () {
	mkdir -p "$1"
	cd "$1"
}

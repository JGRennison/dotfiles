# Copyright © Jonathan G. Rennison 2014 <j.g.rennison@gmail.com>
# License: New BSD License, see BSD-LICENSE.txt

alias ls='ls -h --classify --color=auto'
alias gg='git gui'
alias hv='history | less +G'
DMESG_COLOUR=''
if grep -q -e '--color' < <(dmesg -h 2>&1); then
	DMESG_COLOUR='-L=always'
fi
alias dmt='_dmt() { sudo dmesg "$DMESG_COLOUR" "$@" | tail; }; _dmt'
alias dml='_dml() { sudo dmesg "$DMESG_COLOUR" "$@" | less -R +G; }; _dml'
alias umount_gvfs_smb='gvfs-mount -s smb'
alias newpty='script -q /dev/null'
alias loadalias='. ~/.bash_aliases'
alias openports='netstat -tulanpW'
alias tsf='stdbuf -oL ts "%F %H:%M:%.S %z"'
alias randpass='head -q -c 51 /dev/urandom | base64 -w 0 - | tr -d "/+iIlL1oO0" | head -q -c 15 -; echo'

alias gitka='gitk --all'
alias gitk-merge='gitk --left-right HEAD...MERGE_HEAD'
alias gitk-merge-conflict='gitk --merge --left-right'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'

alias VirtualBox='VirtualBox -style Fusion'
alias virtualbox='virtualbox -style Fusion'

alias sshfst='sshfs -o idmap=user -o transform_symlinks -o ControlPath=none'
function _sshfst() {
	if ! complete -p sshfs &> /dev/null && declare -f -F _completion_loader &> /dev/null; then
		_completion_loader sshfs
	fi
	complete -o nospace -F _sshfs "$1"
	return 124
}
complete -F _sshfst sshfst

function _sshfsa() {
	if ! complete -p sshfs &> /dev/null && declare -f -F _completion_loader &> /dev/null; then
		_completion_loader sshfs
	fi
	_sshfs "$@"
	local reply=( "${COMPREPLY[@]/%\:/}" )
	COMPREPLY=()
	for item in "${reply[@]}"; do [[ $item == */ ]] || COMPREPLY+=("$item"); done
	return 0
}

function sshfsa() {
	TARG="$1"
	shift
	mkdir -p ~/mnt/"$TARG"
	sshfst "$TARG":/ ~/mnt/"$TARG" "$@"
	clearmountpoints
}
complete -F _sshfsa sshfsa

function sshfsar() {
	sshfsa "$@" -o allow_root
}
complete -F _sshfsa sshfsar

function funmount() {
	fusermount -u ~/mnt/"$1"
	clearmountpoints
}

function _funmount() {
	if [ "$COMP_CWORD" -gt 1 ]; then
		return 1
	fi
	COMPREPLY=( $( IFS='/' compgen -W "$(find ~/mnt/ -mindepth 1 -maxdepth 1 -printf '%f/')" -- "${COMP_WORDS[COMP_CWORD]}" ) )
	return 0
}
complete -F _funmount funmount

function clearmountpoints() {
	MNT="`mount`"
	for f in ~/mnt/*; do
		if [ -d "$f" ] && ! grep -q "`readlink -f "$f"`" <<< "$MNT"; then
			rmdir "$f"
		fi
	done
}

function _exec_ssh() {
	if [ "${TERMINAL_TITLE_ENABLED}" != 0 ]; then
		echo -ne "\033]2;${TITLE_TAG:+[${TITLE_TAG}] }ssh $*\007"
	fi

	if which ssh-agent-on-demand &>/dev/null; then
		ssh-agent-on-demand -1dF -f ~/.ssh/sshod_config -e ssh "$@"
	else
		ssh "$@"
	fi
}
alias ssh='_exec_ssh'

if which ssh-agent-on-demand &>/dev/null; then
	alias cssh='ssh-agent-on-demand -1dF -f ~/.ssh/sshod_config -e cssh'
	alias ssh-add='ssh-agent-on-demand -1dF -f ~/.ssh/sshod_config -e ssh-add'
fi

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
	ssh-add -l &> /dev/null
	if [ "$?" -lt 2 ]; then
		echo "Using current SSH Agent socket"
		ssh-add -l
		return
	fi

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

function setgidify () {
	GRP="${1:?No group given}"
	shift
	[ "$#" -lt 1 ] && { echo "No directories given"; return 1; }
	[ "`id -u`" -ne 0 ] && { echo "You are not root"; return 1; }
	chown -R :"$GRP" "$@"
	chmod -R g+w "$@"
	find "$@" -type d -exec chmod g+s {} \;
}

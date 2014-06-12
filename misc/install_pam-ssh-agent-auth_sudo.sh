#!/bin/bash

# Copyright © Jonathan G. Rennison 2014 <j.g.rennison@gmail.com>
# License: New BSD License, see BSD-LICENSE.txt

# This script sets up sudo authentication on the current host via pam_ssh_agent_auth
# Note that this does not setup agent forwarding on the client

# This creates the file /etc/sudoers.d/pam-ssh-agent-auth
# This assumes that a suitable includedir directive is already in /etc/sudoers

. "`dirname "$0"`/../common/util.sh"

sudoers_add_prechecks

if [ '!' -e '/lib/security/pam_ssh_agent_auth.so' ]; then
	echo "pam_ssh_agent_auth does not seem to be installed"
	echo "Type 'y' or 'yes' to install from ppa:cpick/pam-ssh-agent-auth"
	echo "To install from source instead, type 'n', download from:"
	echo "http://sourceforge.net/projects/pamsshagentauth/files/latest/download"
	echo 'install with: `./configure --libexecdir=/lib/security/` `make install`'
	echo "and then re-run this script"
	read -p "" -r
	if [ "$REPLY" == "y" -o "$REPLY" == "yes" ]; then
		apt-get install -y python-software-properties software-properties-common
		apt-add-repository -y ppa:cpick/pam-ssh-agent-auth
		apt-get update -y
		apt-get install -y pam-ssh-agent-auth
		if [ '!' -e '/lib/security/pam_ssh_agent_auth.so' ]; then
			echo "Installation didn't seem to work, aborting"
			exit 1
		fi
	else
		echo "Aborting"
		exit 1
	fi
fi

sudoers_add_tmps "pam-ssh-agent-auth"

cat > "$TMPSUDOERS" << EOL
# This file was created by `readlink -f "$0"` at `date "+%F %T %z"`

Defaults    env_keep += "SSH_AUTH_SOCK"

EOL

PAM="/etc/pam.d/sudo"
TMPPAM=
if ! grep -q "pam_ssh_agent_auth.so" "$PAM"; then
	TMPPAM="`mktemp -t -u "pamd-sudo-XXXXXXXXXXXXXXXXXXXXX"`"
	cp "$PAM" "$TMPPAM"

	function finish2 {
		rm "$TMPPAM"
		finish
	}
	trap finish2 EXIT

	sed -i -e "/@include common-auth/ i auth       sufficient pam_ssh_agent_auth.so file=/etc/ssh/sudo_authorized_keys" "$TMPPAM"

	echo "This will update $PAM as diffed below"
	echo ""
	git --no-pager diff --no-index -- "$PAM" "$TMPPAM"
	echo ""
fi

sudoers_add_install

if [ '!' -e '/etc/ssh/sudo_authorized_keys' ]; then
	touch /etc/ssh/sudo_authorized_keys
	chown root:root /etc/ssh/sudo_authorized_keys
	chmod 644 /etc/ssh/sudo_authorized_keys
fi

if [ -n "$TMPPAM" ]; then
	cp "$TMPPAM" "$PAM"
fi

echo "Type 'y' or 'yes' to edit /etc/ssh/sudo_authorized_keys now"
read -p "" -r
if [ "$REPLY" == "y" -o "$REPLY" == "yes" ]; then
	${EDITOR:-nano} /etc/ssh/sudo_authorized_keys
fi

echo "SSH agent forwarding needs to be on for this to work"
echo "Edit: ~/.ssh/config on the client(s) to include something like:"
echo "host <list of hosts>"
echo "	ForwardAgent yes"

#!/bin/bash

# Copyright © Jonathan G. Rennison 2014 <j.g.rennison@gmail.com>
# License: New BSD License, see BSD-LICENSE.txt

# This script replaces gnome-keyring-daemon with a wrapper which invokes the original
# with the ssh agent disabled.
# This is because it is not otherwise practical to disable its ssh-agent.
# This is based on this post http://askubuntu.com/a/412794 by JanKanis.
# and this post http://askubuntu.com/a/584061 by Matthew Caron.

dpkg-divert --divert /usr/bin/gnome-keyring-daemon-wrapped --rename /usr/bin/gnome-keyring-daemon \
	|| dpkg-divert --divert /usr/bin/gnome-keyring-daemon-wrapped /usr/bin/gnome-keyring-daemon

if [ '!' -f "$HOME/.config/autostart/gnome-keyring-ssh.desktop" ]; then
	echo -e "[Desktop Entry]\nX-GNOME-Autostart-enabled=false" | ${SUDO_USER:+ sudo -u $SUDO_USER} tee "$HOME/.config/autostart/gnome-keyring-ssh.desktop" > /dev/null
	echo "Writing to $HOME/.config/autostart/gnome-keyring-ssh.desktop" >&2
fi

if [ "`readlink -f "/usr/bin/gnome-keyring-daemon"`" == "/usr/bin/gnome-keyring-daemon-wrapper" ]; then
	echo "Wrapper seems to be already installed, aborting" >&2
	exit 1
fi

if [ '!' -w "/usr/bin/" ]; then
	echo "Can't write to /usr/bin/, maybe try as root? Aborting" >&2
	exit 1
fi

if [ -L "/usr/bin/gnome-keyring-daemon" ]; then
	echo "/usr/bin/gnome-keyring-daemon is already a symlink, aborting" >&2
	exit 1
fi

if [ -f "/usr/bin/gnome-keyring-daemon" ]; then
	mv /usr/bin/gnome-keyring-daemon /usr/bin/gnome-keyring-daemon-wrapped
fi
echo '#!/bin/sh' > /usr/bin/gnome-keyring-daemon-wrapper
echo 'exec /usr/bin/gnome-keyring-daemon-wrapped --components=pkcs11,secrets,gpg "$@"' >> /usr/bin/gnome-keyring-daemon-wrapper
chmod +x /usr/bin/gnome-keyring-daemon-wrapper

ln -s /usr/bin/gnome-keyring-daemon-wrapper /usr/bin/gnome-keyring-daemon

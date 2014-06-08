#!/bin/sh

# Copyright © Jonathan G. Rennison 2014 <j.g.rennison@gmail.com>
# License: New BSD License, see BSD-LICENSE.txt

# This script replaces gnome-keyring-daemon with a wrapper which invokes the original
# with the ssh agent disabled.
# This is because it is otherwise overly cumbersome to disable its ssh-agent on some platforms.
# This is based on this post http://askubuntu.com/a/412794 by JanKanis.

if [ -e "/usr/bin/gnome-keyring-daemon-wrapped" ]; then
	echo "Wrapper seems to be already installed, aborting" &>2
	exit 1
fi

if [ '!' -w "/usr/bin/" ]; then
	echo "Can't write to /usr/bin/, maybe try as root? Aborting" &>2
	exit 1
fi

mv /usr/bin/gnome-keyring-daemon /usr/bin/gnome-keyring-daemon-wrapped
echo '#!/bin/sh' > /usr/bin/gnome-keyring-daemon
echo 'exec /usr/bin/gnome-keyring-daemon-wrapped --components=pkcs11,secrets,gpg "$@"' >> /usr/bin/gnome-keyring-daemon
chmod +x /usr/bin/gnome-keyring-daemon

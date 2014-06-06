#!/bin/sh

mv /usr/bin/gnome-keyring-daemon /usr/bin/gnome-keyring-daemon-wrapped
echo '#!/bin/sh' > /usr/bin/gnome-keyring-daemon
echo 'exec /usr/bin/gnome-keyring-daemon-wrapped --components=pkcs11,secrets,gpg "$@"' >> /usr/bin/gnome-keyring-daemon
chmod +x /usr/bin/gnome-keyring-daemon

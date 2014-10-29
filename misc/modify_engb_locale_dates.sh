#!/bin/bash

# Copyright © Jonathan G. Rennison 2014 <j.g.rennison@gmail.com>
# License: New BSD License, see BSD-LICENSE.txt

# This script installs a replacement modified en_GB locale which uses ISO 8601 dates

THISDIR="$(readlink -f $(dirname "$0"))"

if [ -e "/usr/share/i18n/locales/en_GB.orig" ]; then
	echo "Seems to be already installed, aborting" >&2
	exit 1
fi

if [ '!' -w "/usr/share/i18n/locales/" ]; then
	echo "Can't write to /usr/share/i18n/locales/, maybe try as root? Aborting" >&2
	exit 1
fi

mv /usr/share/i18n/locales/en_GB /usr/share/i18n/locales/en_GB.orig
cp "$THISDIR/en_GB@custom" /usr/share/i18n/locales/en_GB
pushd /usr/share/i18n/locales/ &> /dev/null
localedef -f UTF-8 -i en_GB en_GB.UTF-8
popd &> /dev/null

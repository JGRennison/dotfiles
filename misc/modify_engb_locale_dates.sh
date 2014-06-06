#!/bin/sh

mv /usr/share/i18n/locales/en_GB /usr/share/i18n/locales/en_GB.orig
cp en_GB@custom /usr/share/i18n/locales/en_GB
pushd /usr/share/i18n/locales/ &> /dev/null
localedef -f UTF-8 -i en_GB en_GB.UTF-8
popd &> /dev/null

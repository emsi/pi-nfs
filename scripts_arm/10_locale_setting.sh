#!/bin/bash

set -Eeuo pipefail

echo "Setting keyboard to '${PI_KEYMAP}'"
sed -i /etc/default/keyboard -e "s/^XKBLAYOUT.*/XKBLAYOUT=\"${PI_KEYMAP}\"/"

echo "Setting locale to '${PI_LOCALE}'"
echo "${PI_LOCALE}" > /etc/locale.gen
sed -i "s/^\s*LANG=\S*/LANG=$PI_LOCALE/" /etc/default/locale

echo "Setting timezone to '${PI_TIMEZONE}'"
echo "${PI_TIMEZONE}" > /etc/timezone
rm /etc/localtime
ln -sf "/usr/share/zoneinfo/${PI_TIMEZONE}" /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

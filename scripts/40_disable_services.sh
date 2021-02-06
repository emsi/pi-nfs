#!/bin/bash
set -Eeuo pipefail

if [[ -z "${TARGET_PATH-}" ]]; then
	echo >&2 -e "TARGET_PATH not set!"
	exit 1
fi

TARGET_PATH=$(realpath "${TARGET_PATH}")

echo Disabling cron service 
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/cron.service"
rm "${TARGET_PATH}/etc/cron.daily/"*
rm "${TARGET_PATH}/etc/cron.weekly/"*

echo Disabling eepropm update
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/rpi-eeprom-update.service"

echo Disabling raspi-config
rm "${TARGET_PATH}/etc/init.d/raspi-config"

echo Disabling swap service
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/dphys-swapfile.service"

echo Disabling upgrade services
rm "${TARGET_PATH}/etc/systemd/system/timers.target.wants/apt-daily-upgrade.timer"
rm "${TARGET_PATH}/etc/systemd/system/timers.target.wants/apt-daily.timer"

echo Disabling manpage cache
rm "${TARGET_PATH}/etc/systemd/system/timers.target.wants/man-db.timer"

echo Disabling triggerhappy
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/triggerhappy.service"
rm "${TARGET_PATH}/etc/systemd/system/sockets.target.wants/triggerhappy.socket"

echo Disabling WIFI and BT
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/wpa_supplicant.service"
rm "${TARGET_PATH}/etc/systemd/system/bluetooth.target.wants/bluetooth.service"
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/hciuart.service"
cat > "${TARGET_PATH}/etc/modprobe.d/raspi-blacklist.conf" <<EOF
blacklist brcmfmac
blacklist brcmutil
blacklist btbcm
blacklist hci_uart
EOF

echo Disabling avahi multicast DNS
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/avahi-daemon.service"
rm "${TARGET_PATH}/etc/systemd/system/sockets.target.wants/avahi-daemon.socket"

echo "Disabling sshswitch (service that turns on sshd if /boot/ssh is present)"
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/sshswitch.service"


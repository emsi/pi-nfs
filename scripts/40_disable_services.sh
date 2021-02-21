#!/bin/bash
set -Eeuo pipefail

if [[ -z "${TARGET_PATH-}" ]]; then
	echo >&2 -e "TARGET_PATH not set!"
	exit 1
fi

if [[ -z "${RO_ROOT-}" ]]; then
	echo >&2 -e "RO_ROOT not set!"
	exit 1
fi

if [[ -z "${DISABLE_WIFI-}" ]]; then
	echo >&2 -e "DISABLE_WIFI not set!"
	exit 1
fi

if [[ -z "${DISABLE_BT-}" ]]; then
	echo >&2 -e "DISABLE_BT not set!"
	exit 1
fi

if [[ -z "${DISABLE_DHCPCD-}" ]]; then
	echo >&2 -e "DISABLE_DHCPCD not set!"
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

echo Disabling Wi-Fi
if [[ "${DISABLE_WIFI-}" == "yes" ]]; then
	rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/wpa_supplicant.service"
	rm "${TARGET_PATH}/etc/profile.d/wifi-check.sh"
	cat > "${TARGET_PATH}/etc/modprobe.d/raspi-blacklist.conf" <<EOF
blacklist brcmfmac
blacklist brcmutil
EOF
fi


echo Disabling BT
if [[ "${DISABLE_BT-}" == "yes" ]]; then
	rm "${TARGET_PATH}/etc/systemd/system/bluetooth.target.wants/bluetooth.service"
	rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/hciuart.service"
	cat > "${TARGET_PATH}/etc/modprobe.d/raspi-blacklist.conf" <<EOF
blacklist btbcm
blacklist hci_uart
EOF
fi

echo Disabling avahi multicast DNS
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/avahi-daemon.service"
rm "${TARGET_PATH}/etc/systemd/system/sockets.target.wants/avahi-daemon.socket"

echo "Disabling sshswitch (service that turns on sshd if /boot/ssh is present)"
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/sshswitch.service"

if [[ "${DISABLE_DHCPCD-}" == "yes" ]]; then
	echo "Disabling dhcpcd"
	rm "${TARGET_PATH}/etc/systemd/system/dhcpcd5.service"
	rm -rf "${TARGET_PATH}/etc/systemd/system/dhcpcd.service.d/"
	rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/dhcpcd.service"
fi
if [[ "${DNS_RESOLVER-}" != "" ]]; then
	echo "nameserver ${DNS_RESOLVER}" > "${TARGET_PATH}/etc/resolv.conf"
fi

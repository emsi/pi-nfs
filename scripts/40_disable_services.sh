#!/bin/bash

if [[ -z "${TARGET_PATH-}" ]]; then
	echo >&2 -e "TARGET_PATH not set!"
	exit 1
fi

TARGET_PATH=$(realpath "${TARGET_PATH}")

# Disable cron service 
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/cron.service"
rm "${TARGET_PATH}/etc/cron.daily/*"
rm "${TARGET_PATH}/etc/cron.weekly/*"

# Disable eepropm update
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/rpi-eeprom-update.service"

# Disable raspi-config (like boot with shift)
rm "${TARGET_PATH}/etc/init.d/raspi-config"

# Disable swap service
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/dphys-swapfile.service"

# Disable upgrade services
rm "${TARGET_PATH}/etc/systemd/system/timers.target.wants/apt-daily-upgrade.timer"
rm "${TARGET_PATH}/etc/systemd/system/timers.target.wants/apt-daily.timer"

# Disable manpage cache
rm "${TARGET_PATH}/etc/systemd/system/timers.target.wants/man-db.timer"

# Disable triggerhappy
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/triggerhappy.service"
rm "${TARGET_PATH}/etc/systemd/system/sockets.target.wants/triggerhappy.socket"

# Disable WIFI and BT
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/wpa_supplicant.service"
rm "${TARGET_PATH}/etc/systemd/system/bluetooth.target.wants/bluetooth.service"
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/hciuart.service"
cat > "${TARGET_PATH}/etc/modprobe.d/raspi-blacklist.conf" <<EOF
blacklist brcmfmac
blacklist brcmutil
blacklist btbcm
blacklist hci_uart
EOF

# Disable avahi multicast DNS
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/avahi-daemon.service"
rm "${TARGET_PATH}/etc/systemd/system/sockets.target.wants/avahi-daemon.socket"

# Disable sshswitch (turning on sshd if /boot/ssh is present)
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/sshswitch.service"


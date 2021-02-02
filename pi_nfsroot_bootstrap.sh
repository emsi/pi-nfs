#!/bin/bash

set -Eeuo pipefail

if [[ ! -f /etc/exports ]]; then
	echo "No exports. Install nfs server first!"
	echo
	exit -1
fi

pwd=$(pwd)

trap cleanup SIGINT SIGTERM ERR EXIT
cleanup() {
	trap - SIGINT SIGTERM ERR EXIT
	cd "${pwd}"
	exit
}

TARGET_PATH=$(realpath "${TARGET_PATH}")
echo "Bootstraping pi to nfsroot '${TARGET_PATH}'"
mkdir -p "${TARGET_PATH}"
cd "${TARGET_PATH}"

# obtaining and extracting root
if [[ "${DOWNLOAD-}" == "yes" ]]; then
	wget https://downloads.raspberrypi.org/raspios_lite_armhf/root.tar.xz
fi
tar Jxf root.tar.xz --checkpoint=1000 --checkpoint-action=dot
#rm root.tar.xz

# obtainng and extracting boot
if [[ "${DOWNLOAD-}" == "yes" ]]; then
	wget https://downloads.raspberrypi.org/raspios_lite_armhf/boot.tar.xz
fi
cd boot
tar Jxvf ../boot.tar.xz
#rm boot.tar.xz
cd ..


#
# Customizations
#

if [[ "${RO_ROOT-}" == "yes" ]]; then
	# use custom init for ro root
	INIT="init=/bin/ro-root.sh"
	RORW="ro"

	# install ro-root
	curl https://gist.githubusercontent.com/emsi/3c7143f0583566aad14bad182297a104/raw/ -o bin/ro-root.sh
	chmod +x bin/ro-root.sh

	# install netflap reboot watchdog script
	curl https://gist.githubusercontent.com/emsi/899505583dcaeda65b9bab2d5dee9008/raw/netflapdog.py -o bin/netflapdog.py
	chmod +x bin/netflapdog.py
	
	# install netflap reboot watchdog service
	curl https://gist.githubusercontent.com/emsi/27de391670bc4130a521317323628bfa/raw/netflapdog.service -o lib/systemd/system/netflapdog.service
	ln -sf /lib/systemd/system/netflapdog.service etc/systemd/system/sysinit.target.wants/netflapdog.service
else
	RORW="rw"
fi

# customize cmdline.txt
echo "console=serial0,115200 console=tty1 rootwait ro nfsroot=${NFSROOT},v3 ip=dhcp root=/dev/nfs elevator=deadline plymouth.ignore-serial-consoles ${INIT-}" > boot/cmdline.txt

# customize config.txt (enable spi)
if [[ "${SPI_ON-}" == "yes" ]]; then
	sed -i -e 's/^#\(dtparam=spi=on\)/\1/' boot/config.txt
fi

# do not resize root
rm etc/rc3.d/S01resize2fs_once

# clean fstab (without refference to sd card)
echo "proc            /proc           proc    defaults          0       0" > etc/fstab
# this line is not required when ro-root.sh is used for root overlay
if [[ -z "${RO_ROOT-}" ]]; then
	echo "${NFSROOT}       /       nfs     nfsvers=3,tcp   0       1" >> etc/fstab
fi

# Change keyboard
sed -i etc/default/keyboard -e "s/^XKBLAYOUT.*/XKBLAYOUT=\"$KEYMAP\"/"

# Change locale
#
echo "$LOCALE" > etc/locale.gen
sed -i "s/^\s*LANG=\S*/LANG=$LOCALE/" etc/default/locale

# Change timezone
rm etc/localtime
echo "$TIMEZONE" > etc/timezone

#
# Disable and remove unnecessairy services and functions
#

# Disable cron service 
rm etc/systemd/system/multi-user.target.wants/cron.service
rm etc/cron.daily/*
rm etc/cron.weekly/*

# Disable eepropm update
rm etc/systemd/system/multi-user.target.wants/rpi-eeprom-update.service

# Disable raspi-config (like boot with shift)
rm etc/init.d/raspi-config

# Disable swap service
rm etc/systemd/system/multi-user.target.wants/dphys-swapfile.service

# Disable upgrade services
rm etc/systemd/system/timers.target.wants/apt-daily-upgrade.timer
rm etc/systemd/system/timers.target.wants/apt-daily.timer

# Disable manpage cache
rm etc/systemd/system/timers.target.wants/man-db.timer

# Disable triggerhappy
rm etc/systemd/system/multi-user.target.wants/triggerhappy.service
rm etc/systemd/system/sockets.target.wants/triggerhappy.socket

# Disable WIFI and BT
rm etc/systemd/system/multi-user.target.wants/wpa_supplicant.service
rm etc/systemd/system/bluetooth.target.wants/bluetooth.service
rm etc/systemd/system/multi-user.target.wants/hciuart.service
cat > etc/modprobe.d/raspi-blacklist.conf <<EOF
blacklist brcmfmac
blacklist brcmutil
blacklist btbcm
blacklist hci_uart
EOF

# Disable avahi multicast DNS
rm etc/systemd/system/multi-user.target.wants/avahi-daemon.service
rm etc/systemd/system/sockets.target.wants/avahi-daemon.socket

# Disable sshswitch (turning on sshd if /boot/ssh is present)
rm etc/systemd/system/multi-user.target.wants/sshswitch.service

# Disable key generation at boot and generate keys from nfs host
rm etc/systemd/system/multi-user.target.wants/regenerate_ssh_host_keys.service 
ssh-keygen -A -v -f .

# Enable sshd
ln -sf /lib/systemd/system/ssh.service etc/systemd/system/multi-user.target.wants/ssh.service


# add export path
ESCAPED_PATH=$(echo "${TARGET_PATH}" | sed 's/\//\\\//g')
sed -i "/^${ESCAPED_PATH=} /d" /etc/exports
echo "${TARGET_PATH} ${ALLOW_NET}(${RORW},sync,no_subtree_check,no_root_squash)" >> /etc/exports
systemctl restart nfs-kernel-server

cd "$pwd"

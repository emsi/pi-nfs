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

if [[ -z "${NFSROOT-}" ]]; then
	echo >&2 -e "NFSROOT not set!"
	exit 1
fi

if [[ -z "${SPI_ON-}" ]]; then
	echo >&2 -e "NFSROOT not set!"
	exit 1
fi

TARGET_PATH=$(realpath "${TARGET_PATH}")

if [[ "${RO_ROOT-}" == "yes" ]]; then
	# use custom init for ro root
	INIT="init=/bin/ro-root.sh"

	echo Installing ro-root
	curl https://gist.githubusercontent.com/emsi/3c7143f0583566aad14bad182297a104/raw/ -o "${TARGET_PATH}/bin/ro-root.sh"
	chmod +x "${TARGET_PATH}/bin/ro-root.sh"

	echo Installing netflap reboot watchdog script
	curl https://gist.githubusercontent.com/emsi/899505583dcaeda65b9bab2d5dee9008/raw/netflapdog.py -o "${TARGET_PATH}/bin/netflapdog.py"
	chmod +x "${TARGET_PATH}/bin/netflapdog.py"
	
	echo Installing netflap reboot watchdog service
	curl https://gist.githubusercontent.com/emsi/27de391670bc4130a521317323628bfa/raw/netflapdog.service -o "${TARGET_PATH}/lib/systemd/system/netflapdog.service"
	ln -sf /lib/systemd/system/netflapdog.service "${TARGET_PATH}/etc/systemd/system/sysinit.target.wants/netflapdog.service"
fi

echo Customizing cmdline.txt
echo "console=serial0,115200 console=tty1 rootwait ro nfsroot=${NFSROOT},v3 ip=dhcp root=/dev/nfs elevator=deadline plymouth.ignore-serial-consoles ${INIT-}" > "${TARGET_PATH}/boot/cmdline.txt"

echo Customizing config.txt
if [[ "${SPI_ON-}" == "yes" ]]; then
	sed -i -e 's/^#\(dtparam=spi=on\)/\1/' "${TARGET_PATH}/boot/config.txt"
fi

echo Disabling root filesystem resize on first boot
rm "${TARGET_PATH}/etc/rc3.d/S01resize2fs_once"

echo Setting up fstab
# clean fstab (without refference to sd card)
echo "proc            /proc           proc    defaults          0       0" > "${TARGET_PATH}/etc/fstab"
# this line is not required when ro-root.sh is used for root overlay
if [[ "${RO_ROOT-}" != "yes" ]]; then
	echo "${NFSROOT}       /       nfs     nfsvers=3,tcp   0       1" >> "${TARGET_PATH}/etc/fstab"
fi

#!/bin/bash
set -Eeuo pipefail

if [[ -z "${TARGET_PATH-}" ]]; then
	echo >&2 -e "TARGET_PATH not set!"
	exit 1
fi

TARGET_PATH=$(realpath "${TARGET_PATH}")

echo Disabling key generation at first boot
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/regenerate_ssh_host_keys.service"
echo Generating ssh keys
ssh-keygen -A -v -f "${TARGET_PATH}"

echo Enabling sshd
ln -sf /lib/systemd/system/ssh.service "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/ssh.service"


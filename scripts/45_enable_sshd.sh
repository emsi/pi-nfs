#!/bin/bash

if [[ -z "${TARGET_PATH-}" ]]; then
	echo >&2 -e "TARGET_PATH not set!"
	exit 1
fi

TARGET_PATH=$(realpath "${TARGET_PATH}")

# Disable key generation at boot and generate keys from nfs host
rm "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/regenerate_ssh_host_keys.service"
ssh-keygen -A -v -f .

# Enable sshd
ln -sf /lib/systemd/system/ssh.service "${TARGET_PATH}/etc/systemd/system/multi-user.target.wants/ssh.service"


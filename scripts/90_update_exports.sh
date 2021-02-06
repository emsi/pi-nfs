#!/bin/bash

if [[ -z "${TARGET_PATH-}" ]]; then
	echo >&2 -e "TARGET_PATH not set!"
	exit 1
fi

if [[ ! -f /etc/exports ]]; then
	echo "No exports. Install nfs server first!"
	echo
	exit -1
fi

if [[ "${RO_ROOT-}" == "yes" ]]; then
	RORW="ro"
else
	RORW="rw"
fi

ESCAPED_PATH=$(echo "${TARGET_PATH}" | sed 's/\//\\\//g')
sed -i "/^${ESCAPED_PATH=} /d" /etc/exports
echo "${TARGET_PATH} ${ALLOW_NET}(${RORW},sync,no_subtree_check,no_root_squash)" >> /etc/exports
echo restarting nfs-kernel-server
systemctl restart nfs-kernel-server

#!/bin/bash

if [[ -z "${TARGET_PATH-}" ]]; then
	echo >&2 -e "TARGET_PATH not set!"
	exit 1
fi

TARGET_PATH=$(realpath "${TARGET_PATH}")

echo "Extracting ${RASPIOS_VERSION} root to '${TARGET_PATH}'"
tar Jxf "${TARGET_PATH}/root.tar.xz" --checkpoint=1000 --checkpoint-action=dot --directory "${TARGET_PATH}/"

echo "Extracting ${RASPIOS_VERSION} boot to '${TARGET_PATH}'"
tar Jxf "${TARGET_PATH}/boot.tar.xz" --checkpoint=1000 --checkpoint-action=dot --directory "${TARGET_PATH}/boot/"

#!/bin/bash

if [[ -z "${TARGET_PATH-}" ]]; then
	echo >&2 -e "TARGET_PATH not set!"
	exit 1
fi

if [[ -z "${RASPIOS_VERSION-}" ]]; then
	echo >&2 -e "RASPIOS_VERSION not set!"
	exit 1
fi

TARGET_PATH=$(realpath "${TARGET_PATH}")
echo "Downloading ${RASPIOS_VERSION} to '${TARGET_PATH}'"
mkdir -p "${TARGET_PATH}"

curl "https://downloads.raspberrypi.org/${RASPIOS_VERSION}/boot.tar.xz" -o "${TARGET_PATH}/boot.tar.xz"
curl "https://downloads.raspberrypi.org/${RASPIOS_VERSION}/root.tar.xz" -o "${TARGET_PATH}/root.tar.xz"

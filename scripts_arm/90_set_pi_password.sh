#!/bin/bash
set -Eeuo pipefail

if [[ "${PI_SETPASS}" == "yes" ]]; then
	echo "Changing default 'pi' user password."
	echo "Provide new password."
	passwd pi
fi

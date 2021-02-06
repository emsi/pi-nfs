#!/usr/bin/env bash

set -Eeuo pipefail

# read default env
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
. "${script_dir}/ENV"
export $(sed -e '/^[^=]\+=[^=]*$/!d' -e 's/^\([^=]\+\)=.*$/\1/' "${script_dir}/ENV")

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-d] [-D] [-R] target_path

Raspberry pi nfsroot bootstrap script.

Available options:

-h, --help          Print this help and exit
-v, --verbose       Print verbose info (implies dry run)
-d, --debug         Print debug (each run command)
-D, --no-download   Don't download new dist files (fils if not previously downloaded)
-R, --no-ro-root    Don't enabkle read only root with overlay
EOF
}


msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  echo
  usage
  exit "$code"
}

parse_params() {
  while :; do
    case "${1-}" in
    -h | --help) usage && exit ;;
    -d | --debug) set -x ;;
    -v | --verbose) verbose=1 ;;
    -D | --no-download) export DOWNLOAD="no" ;; 
    -R | --no-ro-root) export RO_ROOT="no" ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  [[ ${#args[@]} -eq 0 ]] && die "Missing target_path" 

  return 0
}

parse_params "$@"


TARGET_PATH="${args[0]}"
export TARGET_PATH=$(realpath "${TARGET_PATH}")
NFSROOT="${NFS_IP}:${TARGET_PATH}"

if [[ -n "${verbose-}" ]]; then
	env | grep $(sed -e '/^[^=]\+=[^=]*$/!d' -e 's/^\([^=]\+\)=.*$/\1/' "${script_dir}/ENV" | sed -e ':a; N; $!ba; s/\n/\\\|/g')

	exit
fi


for script in "${script_dir}/scripts/"*; do
	if [[ -x $script ]]; then
		$script
	fi
done

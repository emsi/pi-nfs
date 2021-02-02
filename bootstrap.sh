#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-d] target_path

Raspberry pi nfsroot bootstrap script.

Available options:

-h, --help          Print this help and exit
-v, --verbose       Print verbose info (implies dry run)
-d, --debug         Print debug (each run command)
-D, --no-download   Don't download new dist files (fils if not previously downloaded)
-p, --param         Some param description
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
    -D | --no-download) export NO_DOWNLOAD=1 ;; 
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

BOOTSTRAP="pi_nfsroot_bootstrap.sh"
export TARGET_PATH="${args[0]}"

if [[ -n "${verbose-}" ]]; then
	echo "NO_DOWNLOAD=${NO_DOWNLOAD-}"
	echo "TARGET_PATH=${TARGET_PATH}"

	exit
fi

[[ -x "${BOOTSTRAP}" ]] && "${BOOTSTRAP}"




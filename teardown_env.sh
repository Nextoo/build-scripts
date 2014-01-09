#!/bin/bash
# Tears down the Nextoo sandbox environment

set -e

# Get directory containing scripts
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
	SOURCE="$(readlink "$SOURCE")"
	[[ $SOURCE != /* ]] && SOURCE="$SCRIPT_DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

source "${SCRIPT_DIR}/utils.sh"

function usage() {
	echo -e "${RESET}${GREEN}${BOLD}Nextoo Environment Setup Script${RESET} ${BOLD}version <TAG ME>${RESET}"
	cat <<-EOU
		Usage:	$(basename "${0}") [long option(s)] [option(s)] ...

		Options:
		    -d, --debug		Enable debugging output
		    -f, --force		Use the directory specified by -d even if it exists already
		    -h, --help		Show this message and exit
		    -t, --target	Path to directory containing environment to be torn down

	EOU
}


# Check for rootness
ensure_root

# Control params
FORCE=false
TARGET_DIR=

# Get command-line options
args=$(getopt --shell=bash --options="dfht:" --longoptions="debug,force,help,target:" --name="$(basename "${0}")" -- "$@")
if [[ "$?" -ne '0' ]]; then	error 'Terminating'; exit 1; fi
eval set -- "${args}"

while true; do
	case "$1" in
		-d | --debug)
			DEBUG=true
			shift
			;;

		-f | --force)
			FORCE=true
			shift
			;;

		-h | --help)
			usage
			exit 0
			;;

		-t | --target)
			TARGET_DIR="${2}"
			shift 2
			;;

		--)
			shift;
			break;
			;;

		*)
			usage
			exit 1
			;;
	esac
done

# Create a directory for development
if [[ -z "${TARGET_DIR}" ]]; then
	usage
	error 'Error: Target directory not specified.'
	exit 1
fi

# Real work
status "Unmounting chroot filesystems in '${TARGET_DIR}'..."
while IFS= read -r -d '' x; do
	run umount "${x}"
done < <(cat /proc/mounts | tac | awk -vORS=$'\\0' '{ print $2 }' | xargs -0 -L1 printf '%b\0' | egrep --text --null-data "^${TARGET_DIR}")

status "Teardown complete"

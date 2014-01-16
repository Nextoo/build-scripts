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
		Usage:	$(basename "${0}") [long option(s)] [option(s)] <build_path>...

		Options:
		    -d, --debug		Enable debugging output
		    -h, --help		Show this message and exit

	EOU
}


# Check for rootness
ensure_root

# Control params
TARGET_DIR=

# Get command-line options
args=$(getopt --shell=bash --options="dh" --longoptions="debug,help" --name="$(basename "${0}")" -- "$@")
if [[ "$?" -ne '0' ]]; then	error 'Terminating'; exit 1; fi
eval set -- "${args}"

state=options
while true; do
	case "$1" in
		-d | --debug)
			DEBUG=true
			shift
			;;

		-h | --help)
			usage
			exit 0
			;;

		--)
			state=target_dir
			shift;
			;;

		*)
			case "${state}" in
				target_dir)
					TARGET_DIR="${1}"
					state=too_many_params
					;;

				too_many_params)
					# If there is no additional parameter, work is done
					[[ -z "${1}" ]] && break
					echo "Unrecognized parameter \"${1}\""
					usage
					exit 1
					;;
			esac
			shift
			;;
	esac
done

# Enable debug output if requested
[[ "${DEBUG}" == "true" ]] && set -x

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

exit 0

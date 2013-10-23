#!/bin/bash
# Tears down the NexToo sandbox environment

BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"
YELLOW="\e[33m"


# Control params
DEBUG=false
FORCE=false
SCRIPTS_DIR="${DIR}"
TARGET_DIR=

set -e

function debug() {
	echo -e "${RESET}$(date +%H:%m:%S) ${BOLD}${YELLOW}${*}${RESET}"
}

function finish() {
	[[ "$?" -ne '0' ]] && error "Unsuccessful completion, you may need to clean up now..."
}

function error() {
	echo -e "${RESET}$(date +%H:%m:%S) ${RED}${BOLD}${*}${RESET}" >&2
}

function run() {
	[[ "${DEBUG}" == 'true' ]] && debug "exec \"$*\""
	$*
}


function status() {
	echo -e "${RESET}$(date +%H:%m:%S) ${BOLD}${*}${RESET}"
}

function usage() {
	echo -e "${RESET}${GREEN}${BOLD}NexToo Environment Setup Script${RESET} ${BOLD}version <TAG ME>${RESET}"
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
if [[ $EUID -ne 0 ]]; then
	error "You must be root to run this script"
	exit 1
fi

# Get directory containing scripts
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"


# Get command-line options
args=$(getopt --shell=bash --options="dfht:" --longoptions="debug,force,help,target:" --name="$(basename \"${0}\")" -- "$@")
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
trap finish EXIT

status "Getting mounts in '${TARGET_DIR}'..."
mounts=$(cat /proc/mounts | awk '{ print $2 }' | egrep "^${TARGET_DIR}" | tac)

for x in $mounts; do
	status "Unmounting '${x}'..."
	run umount "${x}"
done

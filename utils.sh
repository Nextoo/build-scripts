#!/bin/bash
# A set of pre-defined variables and common functions used by NexToo scripts

BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"
YELLOW="\e[33m"

set -e

function debug() {
	if [[ "${DEBUG}" == 'true' ]]; then
		echo -e "${RESET}$(date +%Y-%m%d\ %H:%M:%S) ${BOLD}${YELLOW}${*}${RESET}"
	fi
}

function finish() {
	[[ "$?" -ne '0' ]] && error "Unsuccessful completion, you may need to clean up now..."
}

function error() {
	echo -e "${RESET}$(date +%Y-%m%d\ %H:%M:%S) ${RED}${BOLD}${*}${RESET}" >&2
}

function run() {
	local x=0

	debug "exec \"$*\""
	"$@" || x=$?

	if [[ "$x" -ne '0' ]]; then
		error "Running command \"$*\" failed with exit code $x"
	fi

	return $x
}

function status() {
	echo -e "${RESET}$(date +%Y-%m%d\ %H:%M:%S) ${BOLD}${*}${RESET}"
}

function ensure_root() {
	if [[ $EUID -ne 0 ]]; then
		error "You must be root to run this script"
		exit 1
	fi
}

#!/bin/bash
# A set of pre-defined variables and common functions used by NexToo scripts

BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"
YELLOW="\e[33m"

set -e

DEBUG=false

function debug() {
	[[ "${DEBUG}" == 'true' ]] && echo -e "${RESET}$(date +%H:%M:%S) ${BOLD}${YELLOW}${*}${RESET}"
}

function finish() {
	[[ "$?" -ne '0' ]] && error "Unsuccessful completion, you may need to clean up now..."
}

function error() {
	echo -e "${RESET}$(date +%H:%M:%S) ${RED}${BOLD}${*}${RESET}" >&2
}

function run() {
	debug "exec \"$*\""
	$*
}

function status() {
	echo -e "${RESET}$(date +%H:%M:%S) ${BOLD}${*}${RESET}"
}

function ensure_root() {
	if [[ $EUID -ne 0 ]]; then
		error "You must be root to run this script"
		exit 1
	fi
}

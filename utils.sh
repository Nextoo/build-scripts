#!/bin/bash
# A set of pre-defined variables and common functions used by Nextoo scripts

BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"
YELLOW="\e[33m"

set -e

function getDate() {
	if [[ "${PRINT_DATE}" == 'true' ]]; then
		echo "$(date +%Y-%m-%d\ %H:%M:%S)"
	fi
}

function debug() {
	if [[ "${DEBUG}" == 'true' ]]; then
		echo -e "${RESET}$(getDate) ${BOLD}${YELLOW}${*}${RESET}"
	fi
}

function finish() {
	local x=$?
	if [[ "$x" -ne '0' ]]; then
		error "Unsuccessful completion, you may need to clean up now..."
	else
		status "Completed successfully"
	fi
	
	return $x
}

function error() {
	echo -e "${RESET}$(getDate) ${RED}${BOLD}${*}${RESET}" >&2
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
	echo -e "${RESET}$(getDate) ${BOLD}${*}${RESET}"
}

function ensure_root() {
	if [[ $EUID -ne 0 ]]; then
		error "You must be root to run this script"
		exit 1
	fi
}

function define() {
	IFS='\n' read -r -d '' ${1} || true
}

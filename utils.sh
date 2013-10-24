#!/bin/bash
# A set of pre-defined variables and common functions used by NexToo scripts

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
	[[ "${DEBUG}" == 'true' ]] && echo -e "${RESET}$(date +%H:%m:%S) ${BOLD}${YELLOW}${*}${RESET}"
}

function finish() {
	[[ "$?" -ne '0' ]] && error "Unsuccessful completion, you may need to clean up now..."
}

function error() {
	echo -e "${RESET}$(date +%H:%m:%S) ${RED}${BOLD}${*}${RESET}" >&2
}

function run() {
	debug "exec \"$*\""
	$*
}


function status() {
	echo -e "${RESET}$(date +%H:%m:%S) ${BOLD}${*}${RESET}"
}

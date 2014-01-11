#!/bin/bash
# Test my 'utils.sh'

if [ -x utils.sh ]; then
	. utils.sh
else
	BOLD="\e[1m"
	RED="\e[31m"
	RESET="\e[0m"
	echo echo -e "${RESET}$(date +%H:%m:%S) ${RED}${BOLD}'utils.sh' does not exist or is not executable!${RESET}" >&2
	exit 1
fi
echo -e "${RESET}${GREEN}${BOLD}NexToo Environment Setup Script${RESET} ${BOLD}version <TAG ME>${RESET}"
DEBUG=true
debug 'This is a debug message'
DEBUG=false
error 'This is an error message'

MAKE_CONF="/etc/portage/make.conf"

if [[ ! -f "${MAKE_CONF}" ]]; then
	MAKE_CONF="/etc/make.conf"
	if [[ ! -f "${MAKE_CONF}" ]]; then
		# Is this even a gentoo install?
		error "Unable to locate your systems make.conf!"
		exit 1
	fi
fi

status "make.conf located at ${MAKE_CONF}"

status "Updating make.conf"
egrep '^source /var/lib/layman/make.conf$' "${MAKE_CONF}" >/dev/null || echo 'source /var/lib/layman/make.conf' #>> "${MAKE_CONF}"
status "make.conf updated"

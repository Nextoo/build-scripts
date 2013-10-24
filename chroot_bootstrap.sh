#!/bin/bash

# Get directory containing scripts
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
	SOURCE="$(readlink "$SOURCE")"
	[[ $SOURCE != /* ]] && SOURCE="$SCRIPT_DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

source "${SCRIPT_DIR}/utils.sh"

echo -e "${RESET}${GREEN}${BOLD}NexToo Chroot Bootstrap Script${RESET} ${BOLD}version <TAG ME>${RESET}"

status 'Updating environment...'
env-update

status 'Sourcing profile...'
source /etc/profile

export PROMPT_COMMAND="export RETVAL=\${?}"
export PS1="\[$(tput bold)\]\[$(tput setaf 6)\][NexToo] \[$(tput setaf 1)\]\u@\h \[$(tput setaf 4)\]\w \[$(tput setaf 3)\]\${RETVAL} \[$(tput setaf 7)\][\j] \[$(tput setaf 4)\]\\$\[$(tput sgr0)\] "

cd "${HOME}"
set +e

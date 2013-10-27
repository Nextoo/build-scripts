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



status "Configuring USE flags..."
run "${SCRIPT_DIR}/update_use_flags.sh"


# Configure the environment for NexToo
status "Merging 'layman'..."
emerge --noreplace --quiet layman

status "Configuring layman..."
egrep 'http://www.nextoo.org/layman/repositories.xml$' /etc/layman/layman.cfg >/dev/null || sed -i 's/^overlays  : http:\/\/www.gentoo.org\/proj\/en\/overlays\/repositories.xml$/overlays  : http:\/\/www.gentoo.org\/proj\/en\/overlays\/repositories.xml\n\thttp:\/\/www.nextoo.org\/layman\/repositories.xml/' /etc/layman/layman.cfg

status "Syncing layman..."
layman -S

status "Adding NexToo overlay..."
layman --add nextoo

# Set default make.conf file location
MAKE_CONF="/etc/portage/make.conf"

# Make sure the make.conf location is set correctly
if [[ ! -f "${MAKE_CONF}" ]]; then
	MAKE_CONF="/etc/make.conf"
	if [[ ! -f "${MAKE_CONF}" ]]; then
		# Is this even a gentoo install?
		error "Unable to locate your systems make.conf"
		exit 1
	fi
fi

status "Updating system make file..."
egrep '^source /var/lib/layman/make.conf$' "${MAKE_CONF}" >/dev/null || echo 'source /var/lib/layman/make.conf' >> "${MAKE_CONF}"


export MAKEOPTS="-j$(($(nproc) + $(nproc)/2))"



cd "${HOME}"
set +e

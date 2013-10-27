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


status 'Configuring prompt...'
	export PROMPT_COMMAND="export RETVAL=\${?}"
	export PS1="\[$(tput bold)\]\[$(tput setaf 6)\][NexToo] \[$(tput setaf 1)\]\u@\h \[$(tput setaf 4)\]\w \[$(tput setaf 3)\]\${RETVAL} \[$(tput setaf 7)\][\j] \[$(tput setaf 4)\]\\$\[$(tput sgr0)\] "


status 'Locating make.conf...'
	# Set default make.conf file location
	MAKE_CONF="/etc/portage/make.conf"
	# Make sure the make.conf location is set correctly
	if [[ ! -f "${MAKE_CONF}" ]]; then
		MAKE_CONF="/etc/make.conf"
		if [[ ! -f "${MAKE_CONF}" ]]; then
			# Is this even a gentoo install?
			error "Unable to locate your system's make.conf"
			exit 1
		fi
	fi


if ! egrep "^\s*MAKEOPTS=" "${MAKE_CONF}" >/dev/null; then
	ncpus="$(($(nproc) + $(nproc) / 2))"
	status "Configuring MAKEOPTS (-j${ncpus})..."
	echo "MAKEOPTS=\"-j${ncpus}\"" >> "${MAKE_CONF}"
else
	status "Skipped MAKEOPTS configuration (already defined in make.conf)"
fi


if [[ "${NEXTOO_BUILD}" == 'true' ]]; then
	if ! egrep '^\s*FEATURES=' "${MAKE_CONF}" | grep "buildpkg" >/dev/null; then
		status "Enabling portage 'buildpkg' feature..."
		echo 'FEATURES="${FEATURES} buildpkg"' >> "${MAKE_CONF}"
	else
		status "Skipping portage 'buildpkg' feature (already enabled)"
	fi
fi


status "Configuring USE flags..."
	run "${SCRIPT_DIR}/update_use_flags.sh"


status "Merging 'layman'..."
	run emerge --noreplace --quiet app-portage/layman


status "Configuring layman..."
	dest="http://www.nextoo.org/layman/repositories.xml"
	if ! egrep 'http://www.nextoo.org/layman/repositories.xml$' /etc/layman/layman.cfg >/dev/null; then
		#run sed -i "${arg}" /etc/layman/layman.cfg
		run sed -i "/^\s*overlays\s*:/ a\\\\t${dest}" /etc/layman/layman.cfg
	fi


status "Syncing layman..."
	run layman --sync-all


if ! layman --list-local | egrep " * nextoo " >/dev/null; then
	status "Adding NexToo overlay..."
	run layman --add nextoo
else
	status "Skipping add NexToo overlay (already added)"
fi


status "Updating system make file..."
	if ! egrep '^\s*source /var/lib/layman/make.conf$' "${MAKE_CONF}" >/dev/null; then
		echo 'source /var/lib/layman/make.conf' >> "${MAKE_CONF}"
	fi


status "Environment setup complete"

cd "${HOME}"
set +e

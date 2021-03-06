#!/bin/bash

# Defaults
REPOS_CONF="${ROOT}/etc/portage/repos.conf"
# This will get a directory 'portage' added to it under which the Nextoo repo will go
NEXTOO_PATH="/usr/nextoo"
NEXTOO_CHECKOUT_PATH="${ROOT}/${NEXTOO_PATH}"
NEXTOO_PORTAGE_URI=https://github.com/Nextoo/portage-overlay.git

# Get directory containing scripts
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
	SOURCE="$(readlink "$SOURCE")"
	[[ $SOURCE != /* ]] && SOURCE="$SCRIPT_DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

source "${SCRIPT_DIR}/utils.sh"

# Enable debug output if requested
[[ "${DEBUG}" == "true" ]] && set -x

# Exit immediately on any unhandled error
set -e

# are we running as root?
if [[ "${EUID}" -ne '0' ]]; then
	error "You must be root to run this script" >&2
	exit 1
fi

# Check if repo is configured already and bail early if so
if [[ -d "${NEXTOO_CHECKOUT_PATH}"/portage/.git ]]; then
	status 'Nextoo overlay already available'
	exit 0
fi

# we need to have dev-vcs/git installed to clone and update the Nextoo repo
if ! git --version > /dev/null; then
	status "Merging dev-vcs/git..."
	CURL_SSL="openssl" MAKEOPTS=-j10 USE="-* curl ipv6 ssl" emerge --noreplace --quiet dev-vcs/git
fi

# Store the Nextoo repo config info
define NEXTOO_CONF <<EOL
[nextoo]
location = $NEXTOO_PATH/portage
sync-type = git
sync-uri = ${NEXTOO_PORTAGE_URI}
EOL

status "Adding configuration for Nextoo portage repository..."
if [[ -d "${REPOS_CONF}" ]]; then
	# REPOS_CONF is a directory, so check for a file containing the Nextoo repo
	if ! egrep '^\[nextoo\]$' "${REPOS_CONF}"/* >/dev/null; then
		# Don't clobber the data if it exists...
		set -o noclobber
		echo -e "\n${NEXTOO_CONF}" > "${REPOS_CONF}"/nextoo.conf
	fi
elif [[ -f "${REPOS_CONF}" ]]; then
	# REPOS_CONF is a file, so check for the Nextoo repo in the file
	if ! egrep '^\[nextoo\]$' "${REPOS_CONF}" >/dev/null; then
		# Append the Nextoo configuration
		echo -e "\n\n${NEXTOO_CONF}" >> "${REPOS_CONF}"
	fi
else
	# No file or directory for repos.conf so create it (or maybe it was something silly like a device node)
	run mkdir -p "${REPOS_CONF}"
	set -o noclobber
	echo "${NEXTOO_CONF}" > "${REPOS_CONF}"/nextoo.conf
fi

status "Nextoo portage repository config in place, proceeding with installation..."

# Create the Nextoo base directory if it doesn't exist
[[ ! -d "${NEXTOO_CHECKOUT_PATH}" ]] && run mkdir -p "${NEXTOO_CHECKOUT_PATH}"

# Clone the Nextoo portage repository the first time if needed
if [[ ! -d "${NEXTOO_CHECKOUT_PATH}"/portage/.git ]]; then
	cd "${NEXTOO_CHECKOUT_PATH}"
	run git clone "${NEXTOO_PORTAGE_URI}" portage
fi

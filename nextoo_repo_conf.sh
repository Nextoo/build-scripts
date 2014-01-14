#!/bin/bash
REPOS_CONF=/etc/portage/repos.conf
# This will get a directory 'portage' added to it under which the Nextoo repo will go
NEXTOO_PATH=/usr/nextoo
NEXTOO_PORTAGE_URI=https://github.com/Nextoo/portage-overlay.git

# Exit immediately on any unhandled error
set -e

# are we running as root?
if [[ "${EUID}" -ne '0' ]]; then
	echo "You must be root to run this script" >&2
	exit 1
fi

# Store the Nextoo repo config info
read -d '' NEXTOO_CONF << EOL
[nextoo]
	location = $NEXTOO_PATH/portage
	sync-type = git
	sync-uri = ${NEXTOO_PORTAGE_URI}
EOL

echo "Adding configuration for Nextoo portage repository..."
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
	mkdir -p "${REPOS_CONF}"
	set -o noclobber
	echo "${NEXTOO_CONF}" > "${REPOS_CONF}"/nextoo.conf
fi

echo "Nextoo portage repository config in place, proceeding with installation..."

# we need to have dev-vcs/git installed to clone and update the Nextoo repo
echo "Merging git..."
emerge --newuse --update dev-vcs/git

# Create the Nextoo base directory if it doesn't exist
[[ ! -d "${NEXTOO_PATH}" ]] && mkdir -p "${NEXTOO_PATH}"

# Clone the Nextoo portage repository the first time if needed
if [[ ! -d "${NEXTOO_PATH}"/portage ]]; then
	cd "${NEXTOO_PATH}"
	git clone "${NEXTOO_PORTAGE_URI}" portage
fi

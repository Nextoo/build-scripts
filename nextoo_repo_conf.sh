#!/bin/bash
REPOS_CONF_PATH=/etc/portage
REPOS_CONF=$REPOS_CONF_PATH/repos.conf
# This will get a directory 'portage' added to it under which the nextoo repo will go
NEXTOO_PATH=/usr/nextoo
# turn on noisy debug
DEBUG=1

# are we running as root?
if [[ $EUID -ne 0 ]]; then
	echo "You must be root to run this script" >&2
	exit 1
fi

# Store the gentoo repos config info
read -d '' GENTOO_CONF << EOL
[DEFAULT]
main-repo = gentoo

[gentoo]
location = /usr/portage
sync-type = rsync
sync-uri = rsync://gentoo.closest.myvwan.com/gentoo-portage
EOL

# Store the nextoo repos config info
read -d '' NEXTOO_CONF << EOL
[nextoo]
location = $NEXTOO_PATH/portage
sync-type = git
sync-uri = https://github.com/Nextoo/portage-overlay.git
EOL

ERR=""

echo "Adding configuration for Nextoo repo..."
if [[ -e $REPOS_CONF ]]; then
	# repos.conf exists
	if [[ -f $REPOS_CONF ]]; then
		# it's a file
		NTC=$(grep -ic nextoo $REPOS_CONF)
		if [[ $NTC -eq '0' ]]; then
			# but doesn't have a listing for the nextoo repo, so add it
			if [[ -w $REPOS_CONF ]]; then

				echo -e "\n${NEXTOO_CONF}" >> $REPOS_CONF
			else
				# but it's not writable
				ERR="repos.conf is not writable. Please run this script as root."
			fi
		fi
	elif [[ -d $REPOS_CONF ]]; then
		# it's a directory
		if [[ ! -e $REPOS_CONF/nextoo.conf ]]; then
			# it doesn't have a config for the nextoo repo, so create it
			if [[ -w $REPOS_CONF ]]; then
			# it's writable
				echo "${NEXTOO_CONF}" > $REPOS_CONF/nextoo.conf
			else
				# it's not writable
				ERR="repos.conf is not writable. Please run this script as root."
			fi
		fi
	else
		# it's not a file or a directory, but it exists...
		ERR="repos.conf exists but is not a file or a directory. Aborting."
	fi
else
	# it doesn't exist
	if [[ -w $REPOS_CONF_PATH ]]; then
		# but the parent directory is writable
		# so create a repos directory
		mkdir -p $REPOS_CONF
		if [[ $? -eq '0' ]]; then
			# and write the gentoo config
			echo "${GENTOO_CONF}" > $REPOS_CONF/gentoo.conf
			# and write the nextoo config
			echo "${NEXTOO_CONF}" > $REPOS_CONF/nextoo.conf
		else
			ERR="Error creating directory 'repos.conf'."
		fi
	else
		ERR="repos.conf does not exist and the path '${REPOS_CONF_PATH}' is not writable. Please run this script as root."
	fi
fi

if [[ "${ERR}" != "" ]]; then
	echo $ERR >&2
	exit 1
fi

echo "Nextoo repo config in place, proceeding with installation..."

# we need to have dev-vcs/git installed to clone and update the nextoo repo
echo "Installing git, if it's not already installed..."
emerge -1Nu dev-vcs/git

if [[ ! -e $NEXTOO_PATH ]]; then
	# make the nextoo folder
	echo "Creating directory for Nextoo repo"
	mkdir -p $NEXTOO_PATH
	if [[ $? -ne '0' ]]; then
		echo "Error creating Nextoo repo directory." >&2
		exit 1
	fi
	# change to that directory
	echo "Changing to Nextoo repo directory"
	cd $NEXTOO_PATH
	# clone the repository in to that directory
	echo "Cloning Nextoo repo..."
	git clone https://github.com/Nextoo/portage-overlay.git portage
	echo "All done, enjoy :D"
else
	echo "${NEXTOO_PATH} already exists. Skipping installation."
fi

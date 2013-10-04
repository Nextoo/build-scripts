#!/bin/bash

# Define the destination path, the entire root filesystem will be represented at this location before tarballing.
DESTINATION=/test
PACKAGES=$(cat <<END
	www-client/firefox
	kde-base/kde-meta
END
)





required_packages=$(cat <<END
	dev-lang/python:2.7
	sys-apps/portage
END
)



set -e
d="${DESTINATION}"
portage_opts="--ignore-default-opts --usepkgonly --getbinpkgonly --quiet"


# If destination exists, fail because we have to make sure it's clean
if [[ -d "${d}" ]]; then
	echo "Error: Destination \"${d}\" exists, cannot proceed." >&2
	exit 1
fi



mkdir -p "${d}"
cd "${d}"
mkdir -p usr/lib64
cd usr
ln -s lib64 lib
cd "${d}"


export ROOT="${d}"
emerge ${portage_opts} ${required_packages}
emerge ${portage_opts} ${PACKAGES}

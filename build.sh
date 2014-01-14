#!/bin/bash
# Creates a directory in the current directory and performs the setup required for development of Nextoo

CURRENT_STAGE3="20131226"
MIRROR="http://gentoo.closest.myvwan.com/gentoo"

# Internals
ARCH=amd64
#NEXTOO_BUILD=false
SCRIPTS="chroot_bootstrap.sh nextoo_repo_conf.sh update_use_flags.sh utils.sh"

set -e

# Get directory containing scripts
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
	SOURCE="$(readlink "$SOURCE")"
	[[ $SOURCE != /* ]] && SOURCE="$SCRIPT_DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

source "${SCRIPT_DIR}/utils.sh"
trap finish EXIT


function usage() {
	echo -e "${RESET}${GREEN}${BOLD}Nextoo Build Script${RESET} ${BOLD}version <TAG ME>${RESET}"
	cat <<-EOU
		Usage:	$(basename "${0}") [long option(s)] [option(s)] <build path> <profile>

		Options:
		    -b, --build		Configure environment for building binaries (not needed for user systems)
		    -d, --debug		Enable debugging output
		    -f, --force		Use the directory specified by -d even if it exists already
		    -h, --help		Show this message and exit

		An (empty) directory must always be specified as the build path. If not empty, the -f option
		must be present and may lead to unpredictable results.

		The profile is specified as in "nextoo:0.0.1/default/linux/amd64/server/router".

	EOU
}


# Get command-line options
args=$(getopt --shell=bash --options="bdfh" --longoptions="build,debug,force,help" --name="$(basename "${0}")" -- "$@")
if [[ "$?" -ne '0' ]]; then	error 'Terminating'; exit 1; fi
eval set -- "${args}"

state=options

while true; do
	case "$1" in
		-b | --build)
			NEXTOO_BUILD=true
			shift
			;;

		-d | --debug)
			DEBUG=true
			shift
			;;

		-f | --force)
			FORCE=true
			shift
			;;

		-h | --help)
			usage
			exit 0
			;;

		--)
			state=target_dir
			shift
			;;

		*)
			case "${state}" in
				target_dir)
					TARGET_DIR="${1}"
					state=target_profile
					;;

				target_profile)
					TARGET_PROFILE="${1}"
					state=too_many_params
					;;

				too_many_params)
					# If there is no additional parameter, work is done
					[[ -z "${1}" ]] && break
					echo "Unrecognized parameter \"${1}\""
					usage
					exit 1
					;;
			esac
			shift
			;;
	esac
done




# Check for rootness
ensure_root





# Create a directory for development
if [[ -z "${TARGET_DIR}" ]]; then
	usage
	error 'Error: Target directory not specified.'
	exit 1
fi

if [[ -d "${TARGET_DIR}" ]]; then
	if [[ "${FORCE}" != 'true' ]]; then
		error "Error: Directory '${TARGET_DIR}' exists, and -f not specified. Remove and try again."
		exit 1
	fi
fi


if [[ ! -d "${TARGET_DIR}" ]]; then
	status "Creating directory '${TARGET_DIR}'..."
	run mkdir -p "${TARGET_DIR}"
fi

status "Changing working directory to '${TARGET_DIR}'..."
OLD_PWD=$(pwd)
run cd "${TARGET_DIR}"

status 'Downloading the latest Gentoo Stage 3 tarball...'
run wget -nv "${MIRROR}/releases/${ARCH}/current-stage3/stage3-${ARCH}-${CURRENT_STAGE3}.tar.bz2"

status 'Downloading the latest Portage tree...'
run wget -nv "${MIRROR}/snapshots/portage-latest.tar.bz2"

status 'Unpacking Gentoo Stage 3 tarball...'
run tar -xpf stage3-${ARCH}-${CURRENT_STAGE3}.tar.bz2

status 'Unpacking Portage tree...'
run tar -xf portage-latest.tar.bz2 -C usr/

status 'Copying /etc/resolve.conf...'
run cp /etc/resolv.conf etc/

status 'Copying scripts...'
run mkdir -p "${TARGET_DIR}/root/nextoo_scripts"
for script in $SCRIPTS; do
	run cp -a "${SCRIPT_DIR}/${script}" "${TARGET_DIR}/root/nextoo_scripts/"
done

status 'Mounting filesystems...'
run mount -t proc none proc/
run mount --rbind /dev dev/
run mount --rbind /sys sys/

status 'Chrooting...'
run env -i TERM="${TERM}" HOME=/root NEXTOO_BUILD="${NEXTOO_BUILD}" DEBUG="${DEBUG}" TARGET_PROFILE="${TARGET_PROFILE}" chroot "${TARGET_DIR}" /bin/bash --rcfile /root/nextoo_scripts/chroot_bootstrap.sh -i

status "Changing working directory back to '${OLD_PWD}'..."
run cd "${OLD_PWD}"

status 'Cleaning up and tearing down...'
if [[ "${DEBUG}" == 'true' ]]; then
	run "${SCRIPT_DIR}/teardown_env.sh" --target="${TARGET_DIR}" --debug
else
	run "${SCRIPT_DIR}/teardown_env.sh" --target="${TARGET_DIR}"
fi

status "Finished!"

#!/bin/bash
# Creates a directory in the current directory and performs the setup required for development of NexToo

CURRENT_STAGE3="20131010"
MIRROR="http://gentoo.closest.myvwan.com/gentoo"

# Internals
ARCH=amd64


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


function usage() {
	echo -e "${RESET}${GREEN}${BOLD}NexToo Environment Setup Script${RESET} ${BOLD}version <TAG ME>${RESET}"
	cat <<-EOU
		Usage:	$(basename "${0}") [long option(s)] [option(s)] ...

		Options:
		    -d, --debug		Enable debugging output
		    -f, --force		Use the directory specified by -d even if it exists already
		    -h, --help		Show this message and exit
		    -t, --target	Path to directory environment should be created in

		An (empty) directory must always be specified. If not empty, the -f option must be
		present and may lead to unpredictable results.

		Any trailing parameters are passed to chroot for running inside the environment after
		creation. If not provided, a bash shell will be spawned.

	EOU
}


# Get command-line options
args=$(getopt --shell=bash --options="dfht:" --longoptions="debug,force,help,target:" --name="$(basename \"${0}\")" -- "$@")
if [[ "$?" -ne '0' ]]; then	error 'Terminating'; exit 1; fi
eval set -- "${args}"

while true; do
	case "$1" in
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

		-t | --target)
			TARGET_DIR="${2}"
			shift 2
			;;

		--)
			shift;
			break;
			;;

		*)
			usage
			exit 1
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

status 'Mounting filesystems...'
run mount -t proc none proc/
run mount --rbind /dev dev/
run mount --rbind /sys sys/

status 'Copying /etc/resolve.conf...'
run cp /etc/resolv.conf etc/

status 'Copying scripts...'
run cp "${SCRIPT_DIR}/utils.sh" "${TARGET_DIR}/root/"
run cp "${SCRIPT_DIR}/nextoo_init.sh" "${TARGET_DIR}/root/"

#copy script into the env to run more commands, like env-update and source
status 'Chrooting...'
run env -i TERM="${TERM}" HOME=/root chroot . /bin/bash -i /root/nextoo_init.sh

status "Changing working directory back to '${OLD_PWD}'..."
run cd "${OLD_PWD}"

status 'Cleaning up and tearing down...'
if [[ "${DEBUG}" == 'true' ]]; then
	run "${SCRIPT_DIR}/teardown_env.sh" --target="${TARGET_DIR}" --debug
else
	run "${SCRIPT_DIR}/teardown_env.sh" --target="${TARGET_DIR}"
fi

debug "Post teardown"

exit 0

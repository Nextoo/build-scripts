#!/bin/bash
# Creates a directory in the current directory and performs the setup required for development of Nextoo

# Internals
SCRIPTS="chroot_bootstrap.sh nextoo_repo_conf.sh update_use_flags.sh utils.sh"

# Exit immediately on failure
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


function get_arch() {
	local arch=$(uname -m)
	arch=${arch/x86_64/amd64}
	echo $arch
}

function get_latest_stage_tarball_filename() {
	data=$(wget -nv -O- "${MIRROR}/releases/${ARCH}/autobuilds/latest-stage3.txt" | grep -v "hardened" | grep -v "nomultilib" | grep "stage3-amd64-" )
	if [[ "$?" -ne '0' ]]; then
		error "Error determining latest stage3 tarball filename"
		exit 1
	fi
	
	echo $data
}

function usage() {
	echo -e "${RESET}${GREEN}${BOLD}Nextoo Build Script${RESET} ${BOLD}version <TAG ME>${RESET}"
	cat <<-EOU
		Usage:	$(basename "${0}") [long option(s)] [option(s)] <build path> <profile>

		Options:
		    -a, --arch		Architecture to build (defaults to the output of 'uname -m')
		    -b, --build		Configure environment for building binaries (not needed for user systems)
		    -d, --debug		Enable debugging output
		    -f, --force		Use the directory specified by -d even if it exists already
		    -h, --help		Show this message and exit
		    -m, --mirror	Specify the mirror for getting Gentoo sources (default: distfiles.gentoo.org)
		    -t, --timestamps	Enable timestamps in debug and status output
		
		Arch:
		    Currently we support 'x86' and 'amd64'. If you don't know, don't worry - auto detection
		    usually works :)

		Build path:
		    An (empty) directory must always be specified as the build path. If not empty, the -f option
		    must be present and may lead to unpredictable results.

		Profile:
		    Full Nextoo profile names look like "nextoo:default/linux/amd64/server/router".
		    Because that's a pain to type, you only need to provide the elements which come after the
		    architecture. For the amd64 router profile, you'd specify "server/router".

	EOU
}

# Assign defaults
ARCH="$(get_arch)"
MIRROR="http://distfiles.gentoo.org"


# Get command-line options
set +e
args=$(getopt --shell=bash --options="abdfhmt" --longoptions="arch:,build,debug,force,help,mirror:,timestamps" --name="$(basename "${0}")" -- "$@")
if [[ "$?" -ne '0' ]]; then
	usage
	exit 1 
fi
set -e
eval set -- "${args}"

state=options
while [[ ! -z "${1}" ]]; do
	case "${1}" in
		-a | --arch)
			shift
			ARCH=$1
			shift
			;;

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
			
		-m | --mirror)
			shift
			MIRROR=$1
			shift
			;;
			
		-t | --timestamps)
			PRINT_DATE_TIMESTAMP=true
			shift
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
					#[[ -z "${1}" ]] && break
					error "Unrecognized parameter \"${1}\""
					usage
					exit 1
					;;
				
				*)
					error "Unknown state \"${state}\" during parameter processing"
					exit 1
					;;
			esac
			shift
			;;
	esac
done


# Enable debug output if requested
[[ "${DEBUG}" == "true" ]] && set -x


# Validate command-line argument for directory
if [[ -z "${TARGET_DIR}" ]]; then
	usage
	error 'Error: Target directory not specified.'
	exit 1
fi

# Validate command-line argument for profile
if [[ -z "${TARGET_PROFILE}" ]]; then
	usage
	error 'Error: Target profile not specified.'
	exit 1
fi

# Check for rootness
ensure_root


# Verify the target directory does not exist
if [[ -d "${TARGET_DIR}" ]]; then
	if [[ "${FORCE}" != 'true' ]]; then
		error "Error: Directory '${TARGET_DIR}' exists, and -f not specified. Remove and try again."
		exit 1
	fi
fi

# Create a directory for development
if [[ ! -d "${TARGET_DIR}" ]]; then
	status "Creating directory '${TARGET_DIR}'..."
	run mkdir -p "${TARGET_DIR}"
fi





# Begin installation
status "Changing working directory to '${TARGET_DIR}'..."
OLD_PWD=$(pwd)
run cd "${TARGET_DIR}"


status "Determining the latest Gentoo Stage 3 tarball..."
TARBALL=$(get_latest_stage_tarball_filename)
debug "Using tarball '${TARBALL}'"

status 'Downloading the latest Gentoo Stage 3 tarball...'
run wget -nv "${MIRROR}/releases/${ARCH}/autobuilds/${TARBALL}"

status 'Downloading the latest Portage tree...'
run wget -nv "${MIRROR}/snapshots/portage-latest.tar.bz2"

status 'Unpacking Gentoo Stage 3 tarball...'
# BUG BUG BUG This should uset he actual filename we downloaded...
run tar -xpf ${TARBALL##*/}

status 'Unpacking Portage tree...'
run tar -xf portage-latest.tar.bz2 -C usr/

status 'Copying /etc/resolve.conf...'
run cp /etc/resolv.conf etc/

status 'Copying scripts...'
run mkdir -p "${TARGET_DIR}/root/nextoo_scripts"
for script in $SCRIPTS; do
	run cp -a "${SCRIPT_DIR}/${script}" "${TARGET_DIR}/root/nextoo_scripts/"
done

status 'Deploying Nextoo overlay...'
	export ROOT="${TARGET_DIR}"
	run "${SCRIPT_DIR}/nextoo_repo_conf.sh"

status 'Mounting filesystems...'
run mount -t proc none proc/
run mount --rbind /dev dev/
run mount --rbind /sys sys/

status 'Chrooting...'
run env -i TERM="${TERM}" HOME=/root ARCH="${ARCH}" NEXTOO_BUILD="${NEXTOO_BUILD}" DEBUG="${DEBUG}" TARGET_PROFILE="${TARGET_PROFILE}" chroot "${TARGET_DIR}" /bin/bash --rcfile /root/nextoo_scripts/chroot_bootstrap.sh -i

status "Changing working directory back to '${OLD_PWD}'..."
run cd "${OLD_PWD}"

status 'Cleaning up and tearing down...'
run env -i DEBUG="${DEBUG}" "${SCRIPT_DIR}/teardown_env.sh" "${TARGET_DIR}"

status "Finished!"

exit 0

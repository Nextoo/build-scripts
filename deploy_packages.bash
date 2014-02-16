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


function usage() {
	echo -e "${RESET}${GREEN}${BOLD}Nextoo Build Script${RESET} ${BOLD}version <TAG ME>${RESET}"
	cat <<-EOU
		Usage:	$(basename "${0}") [long option(s)] [option(s)] <source path> <destination path>

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
			state=source_dir
			shift
			;;

		*)
			case "${state}" in
				source_dir)
					SOURCE_DIR="${1}"
					state=target_dir
					;;

				target_dir)
					TARGET_DIR="${1}"
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
if [[ -z "${SOURCE_DIR}" ]]; then
	usage
	error 'Error: Target directory not specified.'
	exit 1
fi

# Validate source dir exists
if [[ ! -d "${SOURCE_DIR}" ]]; then
	usage
	error 'Error: <source path> was not a valid directory or does not exist.'
	exit 1
fi

# Validate command-line argument for profile
if [[ -z "${TARGET_DIR}" ]]; then
	usage
	error 'Error: Target profile not specified.'
	exit 1
fi

# Verify the target directory does not exist
if [[ -d "${TARGET_DIR}" ]]; then
	debug 'Target directory exists and a merge will be performed'
fi

# Create a directory for development
if [[ ! -d "${TARGET_DIR}" ]]; then
	status "Creating directory '${TARGET_DIR}'..."
	run mkdir -p "${TARGET_DIR}"
fi

function validate_packages_source_dir() {
	if [[ ! -f "${SOURCE_DIR}/Packages" ]]; then
		error 'A Packages manifest/index file is not in the source directory provided. Assuming wrong source dir and exiting!'
		exit 1
	fi
}

function copy_packages_to_target() {
	status "Coping packages from ${SOURCE_DIR} to ${TARGET_DIR} ..."
	rsync -urv --exclude="/Packages" "${SOURCE_DIR}"/* "${TARGET_DIR}"
}


function merge_manifest_files() {
	local a="${1}"
	local b="${2}"
	local out="${3}"

	
}

function merge_manifests() {

	# flow:
	#	- pull remote manifest
	#	- merge
	#	- make backup of target's manifests
	#	- publish new manifests

	local REMOTE_MANIFEST="${TARGET_DIR}/Packages"
	local input_manifest="/tmp/Packages.in.$$"
	local output_manifest="/tmp/Packages.out.$$"
	
	
	debug 'Fetching remote manifest from "${REMOTE_MANIFEST}"...'
	
	rsync "${REMOTE_MANIFEST}" "${input_manifest}"
	merge_manifest_Files "${SOURCE_DIR}/Packages" "/tmp/Packages.in.$$" "${output_manifest}"
}

# General flow:
#	- validate source, target, credentials, etc
#	- copy the packages over
#	- merge manifests

validate_packages_source_dir
copy_packages_to_target
merge_manifests


status 'Success'


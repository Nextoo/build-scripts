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
	echo -e "${RESET}${GREEN}${BOLD}Nextoo Deploy Packages Script${RESET} ${BOLD}version <TAG ME>${RESET}"
	cat <<-EOU
		Usage:	$(basename "${0}") [long option(s)] [option(s)] <base manifest path> <delta manifest path> <output manifest path>

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
			state=base_dir
			shift
			;;

		*)
			case "${state}" in
				base_dir)
					BASE_DIR="${1}"
					state=delta_dir
					;;

				delta_dir)
					DELTA_DIR="${1}"
					state=output_dir
					;;
					
				output_dir)
					OUTPUT_DIR="${1}"
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


# Validate command-line argument
if [[ -z "${BASE_DIR}" ]]; then
	usage
	error 'Error: Base manifest directory is undefined.'
	exit 1
fi

# Validate command-line argument
if [[ -z "${DELTA_DIR}" ]]; then
	usage
	error 'Error: Delta manifest directory is undefined.'
	exit 1
fi

# Verify Delta manifest directory exists
if [[ -d "${DELTA_DIR}" ]]; then
	debug 'Delta directory does not exist.'
fi

# Validate command-line argument
if [[ -z "${OUTPUT_DIR}" ]]; then
	usage
	error 'Error: Outpout manifest directory is undefined.'
	exit 1
fi


function validate_packages_source_dir() {
	if [[ ! -f "${DELTA_DIR}/Packages" ]]; then
		error 'A Packages manifest/index file, that Portage cares about, is not in the source directory provided. Assuming wrong delta manifest dir and exiting!'
		exit 1
	fi
	
	if [[ ! -f "${DELTA_DIR}/packages/Packages" ]]; then
		error 'A Packages manifest/index file, that Portage does not care about, is not in the source directory provided. Assuming wrong delta manifest dir and exiting!'
		exit 1
	fi
}

function copy_packages_to_target() {
	status "Coping packages from ${DELTA_DIR} to ${OUTPUT_DIR} ..."
	rsync -urv --exclude="/Packages" "${DELTA_DIR}"/* "${OUTPUT_DIR}"
}


function merge_manifest_files() {
	local remote_manifest="${BASE_DIR}/packages/Packages"
	local base_manifest="/tmp/Packages.base.$$"
	local built_manifest="${DELTA_DIR}/packages/Packages"
	local output_manifest="/tmp/Packages.out.$$"
	
	debug 'Fetching remote manifest from "${remote_manifest}"...'
	rsync "${remote_manifest}" "${base_manifest}"
	
	if [[ $? != 0 ]]; then
		error 'Failed to fetch the remote manifest from "${remote_manifest}"'
		exit 1
	fi

	./manifest_merge.rb "${base_manifest}" "${built_manifest}" "${output_manifest}"
	
	if [[ $? != 0 ]]; then
		error 'Failed to merge the manifest files.'
		exit 1
	fi
	
	debug 'Publishing merged manifest to "${remote_manifest}"...'
	rsync "${output_manifest}" "${remote_manifest}"
	
	if [[ $? != 0 ]]; then
		error 'Failed to publish the merged manifest from "${remote_manifest}"'
		exit 1
	fi
}

function update_top_manifest_uri() {
	local remote_manifest="${BASE_DIR}/Packages"
	local base_manifest="/tmp/TopPackages.base.$$"
	local built_manifest="${DELTA_DIR}/Packages"
	local output_manifest="/tmp/TopPackages.out.$$"
	
	debug 'Fetching remote manifest from "${remote_manifest}"...'
	rsync "${remote_manifest}" "${base_manifest}"
	
	if [[ $? != 0 ]]; then
		error 'Failed to fetch the remote manifest from "${remote_manifest}"'
		exit 1
	fi

	./update_header.rb "${base_manifest}" "${built_manifest}" "${output_manifest}"
	
	if [[ $? != 0 ]]; then
		error 'Failed to merge the manifest files.'
		exit 1
	fi
}

function merge_manifests() {

	# flow:
	#	- pull remote manifest
	#	- merge
	#	- make backup of target's manifests
	#	- publish new manifests

	# TODO
	# These functions are not fully working yet
	merge_manifest_files
	
	update_top_manifest_uri
}

validate_packages_source_dir
copy_packages_to_target
merge_manifests


status 'Success'


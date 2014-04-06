#!/bin/bash

# Get directory containing scripts
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
	SOURCE="$(readlink "$SOURCE")"
	[[ ${SOURCE} != /* ]] && SOURCE="$SCRIPT_DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

source "${SCRIPT_DIR}/utils.sh"


function usage() {
	echo -e "${RESET}${GREEN}${BOLD}Nextoo Deploy Packages Script${RESET} ${BOLD}version <TAG ME>${RESET}"
	cat <<-EOU
		Usage:	$(basename "${0}") [long option(s)] [option(s)] <base manifest path> <delta manifest path> <output manifest path> <top packages uri>

		<base manifest path>
			Location of existing packages to to merge in with new packages. If this does not exist, the delta manifiest and packages will still be copied to the output.
				*NOTE* Packages from this location are not copied to the output location. It is assumed for now that the output and base will be the same.
			
		<delta manifest path>
			Location of the /usr/packages/ directory for the newly build packages and manifest file.
			
		<output manifest path>
			Location to copy new packages and place merged manifest.
		
		<top packages uri>
			Location to place the new manifest with the added URI to the head.
		
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
					debug "BASE_DIR set to '${BASE_DIR}'"
					state=delta_dir
					;;

				delta_dir)
					DELTA_DIR="${1}"
					debug "DELTA_DIR set to '${DELTA_DIR}'"
					state=output_dir
					;;
					
				output_dir)
					OUTPUT_DIR="${1}"
					debug "OUTPUT_DIR set to '${OUTPUT_DIR}'"
					state=packages_uri
					;;

				packages_uri)
					PACKAGES_URI="${1}"
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

# Validate command-line argument
if [[ -z "${PACKAGES_URI}" ]]; then
	usage
	error 'Error: Packages URI was not provided'
	exit 1
fi

function validate_packages_source_dir() {
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
	# $1 - base manifest
	# $2 - built manifest
	# $3 - output manifest

	./manifest_merge.rb "${1}" "${2}" "${3}"
	
	if [[ $? != 0 ]]; then
		error 'Failed to merge the manifest files.'
		exit 1
	fi
	
	debug "Publishing merged manifest to '${remote_manifest}'..."
	rsync "${output_manifest}" "${remote_manifest}"
	
	if [[ $? != 0 ]]; then
		error "Failed to publish the merged manifest from '${remote_manifest}'"
		exit 1
	fi
}

function update_top_manifest_uri() {
	# $1 - input file
	# $2 - output file
	# $3 - uri

	./update_header.rb "${1}" "${2}" "${3}"
	
	if [[ $? != 0 ]]; then
		error 'Failed to merge the manifest files.'
		exit 1
	fi
}

function merge_manifests() {
	# $1 - remote path
	# $1 - output package manifest
	# $2 - output manifest with URI

	# flow:
	#	- pull remote manifest
	#	- merge
	#	- make backup of target's manifests
	#	- publish new manifests

	local remote_manifest="${1}/packages/Packages"
	local base_manifest="/tmp/Packages.base.$$" #the remote manifest will be stored here and treated as the base
	local built_manifest="${DELTA_DIR}/Packages"

	debug "Fetching remote manifest from '${remote_manifest}'..."
	#rsync "${remote_manifest}" "${base_manifest}"
	wget "${remote_manifest}" -O "${base_manifest}"

	if [[ $? != 0 ]]; then
		error "Failed to fetch the remote manifest from '${remote_manifest}'"
		exit 1
	fi

	merge_manifest_files "${base_manifest}" "${built_manifest}" "${2}"
	
	update_top_manifest_uri "${2}" "${3}" "${PACKAGES_URI}"
}

function publish_new_manifests() {
	# $1 - remote path
	# $2 - output package manifest
	# $3 - output manifest with URI

	local remote_packages_manifest="${1}/packages/Packages"
	local remote_manifest_uri="${1}/Packages"

	debug "Pushing package manifest to remote: '${remote_packages_manifest}'..."
	rsync "${2}" "${remote_packages_manifest}"

	if [[ $? != 0 ]]; then
		error "Failed to push manifest to remote: '${remote_packages_manifest}'"
		exit 1
	fi

	debug "Pushing package manifest with URI to remote: '${remote_manifest_uri}'..."
	rsync "${3}" "${remote_manifest_uri}"

	if [[ $? != 0 ]]; then
		error "Failed to push manifest to remote: '${remote_manifest_uri}'"
		exit 1
	fi

}

function work() {

	local output_manifest="/tmp/Packages.out.$$"
	local output_manifest_with_uri="/tmp/Packages.out.uri.$$"
	local output_staging_dir="output/"
	
	debug 'Creating output staging directory...'
	mkdir -p "${output_staging_dir}/packages"

	validate_packages_source_dir
	#copy_packages_to_target
	merge_manifests "${BASE_DIR}" "${output_manifest}" "${output_manifest_with_uri}"
	publish_new_manifests "${output_staging_dir}" "${output_manifest}" "${output_manifest_with_uri}"

}

# Call main work function
work

status 'Success'


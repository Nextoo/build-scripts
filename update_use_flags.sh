#!/bin/bash

# Configures global and per-packages USE flags


# Get directory containing scripts
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
	SOURCE="$(readlink "$SOURCE")"
	[[ $SOURCE != /* ]] && SOURCE="$SCRIPT_DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

source "${SCRIPT_DIR}/utils.sh"




# (eventually source some config here)
NEXTOO_GLOBAL_USE="X"
NEXTOO_PACKAGE_USE_app_arch__p7zip="wxwidgets"

function update_global_use() {
	local oldifs="${IFS}"

	IFS=" \t\n"
	for flag in ${NEXTOO_GLOBAL_USE}; do
		if [[ "${flag:0:1}" == '-' ]]; then
			# Because euse is broken and returns nonzero if the flag is already disabled, we have to check first
			if euse -a "${flag:1}" | egrep "^\s*${flag:1}" > /dev/null; then
				run euse -D "${flag:1}"
			fi
		else
			# Because euse is broken and returns nonzero if the flag is already enabled, we have to check first
			if ! euse -a "${flag:1}" | egrep "^\s*${flag:1}" > /dev/null; then
				run euse -E "${flag}"
			fi
		fi
	done

	IFS="${oldifs}"
}

function update_package_use {
	local category="${1}" package="${2}" flags="${3}"
	local oldifs="${IFS}"

	IFS=" 	\n"
	for flag in ${flags}; do
		if [[ "${flag:0:1}" == '-' ]]; then
			run euse -p "${category}/${package}" -D "${flag:1}"
		else
			run euse -p "${category}/${package}" -E "${flag}"
		fi
	done

	IFS="${oldifs}"
}


# Grabs environment variables starting with NEXTOO_PACKAGE_USE_ and calls update_package_use for each one
# Package atoms have - replaced with _, and / replaced with __.  For example: sys_kernel__nextoo_sources
function parse_environment {
	local atom category package variable
	local oldifs="${IFS}"

	IFS="\n"
	for x in $(set | egrep "^NEXTOO_PACKAGE_USE_"); do
		atom="${x#NEXTOO_PACKAGE_USE_}"
		atom="${atom//__//}"
		atom="${atom//_/-}"
		category="${atom%%/**}"
		package="${atom##**/}"
		package="${package%%=**}"
		variable="${x%%=**}"

		update_package_use "${category}" "${package}" "${!variable}"
	done

	IFS="${oldifs}"
}

status "Merging 'app-portage/gentoolkit'..."
run emerge --noreplace --quiet app-portage/gentoolkit

status "Updating system and package USE flags..."
parse_environment
update_global_use

#!/bin/bash

# The packages directory
PKGSDIR=/usr/portage/packages
# The packages file name, default: Packages
PKGSFILE=../Packages

# Some styles to work with
BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"
YELLOW="\e[33m"

# Some global variables to help with our endeavor
PKG="" # Package name
MD5="" # Package MD5 sum
SHA1="" # Package SHA1 sum
SIZE="" # Package size

CHECK_MD5=0
CHECK_SHA1=0
CHECK_SIZE=0

# Work begins
set -e

# Fix bashs internal field seperator to use newlines instead of spaces
IFS=$'\n';

getstr() {
	echo $(echo $1 | awk '{print $2}')
}

verify() {
	# If the package name is blank, we can't do much
	if [[ $PKG == "" ]]; then
		return 0
	fi

	# Get actual package size
	## BUG ALERT: we are always assuming the package ends with ".tbz2"
	local P=$PKGSDIR/$PKG.tbz2
	
	# If the file is missing, we can't do any further testing
	if [[ ! -e $P ]]; then
		echo -e "${RESET}${BOLD}${PKG} ${RED}File missing${RESET}"
		return 0
	fi

	# Some local variables to store test results and formatted strings
	local AS=""
	local AMD5=""
	local ASHA1=""
	local MD=""
	local SH=""
	local SZ=""
	local RESULT="${BOLD}${PKG}"

	if [[ "${CHECK_SIZE}" -eq 1 ]]; then
		AS=$(stat -c%s $P)
		# Make sure we have both the recorded size and the files actual size
		if [[ $SIZE == "" || $AS == "" ]]; then
			SZ="${YELLOW}"
		else
			# Compare size
			[[ $AS == $SIZE ]] && SZ="${GREEN}" || SZ="${RED}"
		fi
		# Format for echo
		RESULT="${RESULT} ${SZ}SIZE"
	fi

	if [[ "${CHECK_MD5}" -eq 1 ]]; then
		AMD5=$(md5sum $P | awk '{print $1}')
		# Make sure we have both the recorded MD5 and the files actual MD5
		if [[ $MD5 == "" || $AMD5 == "" ]]; then
			MD="${YELLOW}"
		else
			# Compare MD5
			[[ $AMD5 == $MD5 ]] && MD="${GREEN}" || MD="${RED}"
		fi
		# Format for echo
		RESULT="${RESULT} ${MD}MD5"
	fi

	if [[ "${CHECK_SHA1}" -eq 1 ]]; then
		ASHA1=$(sha1sum $P | awk '{print $1}')
		# Make sure we have both the recorded SHA1 and the files actual SHA1
		if [[ $SHA1 == "" || $ASHA1 == "" ]]; then
			SH="${YELLOW}"
		else
			# Compare SHA1
			[[ $ASHA1 == $SHA1 ]] && SH="${GREEN}" || SH="${RED}"
		fi
		# Format for echo
		RESULT="${RESULT} ${SH}SHA1"
	fi

	# Echo results
	echo -e "${RESET}${RESULT}${RESET}"
}

function usage() {
	echo -e "${RESET}${GREEN}${BOLD}Nextoo Verify Binaries Script${RESET} ${BOLD}version <TAG ME>${RESET}"
	cat <<-EOU
		Usage:	$(basename "${0}") [option(s)] [binary packages path]

		Options:
		    --md5		Run MD5 tests
		    --sha1		Run SHA1 test
		    --size		Make sure the binary size is correct
		    -a, --all		Run all tests
		    -h, --help		Show this message and exit
		
		If the binary packages path is not set, /usr/portage/packages is used.

	EOU
}
# eval set -- "${args}"
while true; do
	case "$1" in
		--md5)
			CHECK_MD5=1
			shift
			;;

		--sha1)
			CHECK_SHA1=1
			shift
			;;

		--size)
			CHECK_SIZE=1
			shift
			;;

		-a | --all)
			CHECK_MD5=1
			CHECK_SHA1=1
			CHECK_SIZE=1
			shift
			;;

		-h | --help)
			usage
			exit 0
			;;

		*)
			break
			;;
	esac
done

if [[ "${CHECK_MD5}" -ne 1 && "${CHECK_SHA1}" -ne 1 && "${CHECK_SIZE}" -ne 1 ]]; then
	usage
	exit 1
fi
if [[ ${1} != "" ]]; then
	PKGSDIR="${1}"
fi

while read line; do
	# If this line starts with 'CPV', it's the package name so record it
	if [[ $line == CPV* ]]; then
		PKG=$(getstr $line)
	# If this line starts with 'SIZE', record this as the file size
	elif [[ $CHECK_SIZE && $line == SIZE* ]]; then
		SIZE=$(getstr $line)
	# If this line start with 'MD5', record this as the file MD5 sum
	elif [[ $CHECK_MD5 && $line == MD5* ]]; then
		MD5=$(getstr $line)
	# If this file contains 'SHA1', record this as the file SHA1 sum
	elif [[ $CHECK_SHA1 && $line == SHA1* ]]; then
		SHA1=$(getstr $line)
	# If this line is blank and the package name is not blank, we have most likely collected all the info we need to verify the file
	elif [[ $line == "" && $PKG != "" ]]; then
		verify
		# After file verfication, reset the variables
		PKG=""
		MD5=""
		SHA1=""
		SIZE=""
	fi
done < "$PKGSDIR/$PKGSFILE"

# Just in case the loop doesn't catch the last package...
if [[ $line == "" && $PKG != "" ]]; then
	verify
fi

# Return bashs internal field seperator to normal
IFS=$' '

set +e
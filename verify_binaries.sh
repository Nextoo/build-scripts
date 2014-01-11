#!/bin/bash

# The packages directory
PKGSDIR=/usr/portage/packages
# The packages file name, default: Packages
PKGSFILE=Packages

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
	local AMD5=$(md5sum $P | awk '{print $1}')
	local ASHA1=$(sha1sum $P | awk '{print $1}')
	local AS=$(stat -c%s $P)
	local MD=""
	local SH=""
	local SZ=""

	# Make sure we have both the recorded MD5 and the files actual MD5
	if [[ $MD5 == "" || $AMD5 == "" ]]; then
		MD="${YELLOW}"
	else
		# Compare MD5
		[[ $AMD5 == $MD5 ]] && MD="${GREEN}" || MD="${RED}"
	fi
	# Format for echo
	MD="${MD}MD5"

	# Make sure we have both the recorded SHA1 and the files actual SHA1
	if [[ $SHA1 == "" || $ASHA1 == "" ]]; then
		SH="${YELLOW}"
	else
		# Compare SHA1
		[[ $ASHA1 == $SHA1 ]] && SH="${GREEN}" || SH="${RED}"
	fi
	# Format for echo
	SH="${SH}SHA1"

	# Make sure we have both the recorded size and the files actual size
	if [[ $SIZE == "" || $AS == "" ]]; then
		SZ="${YELLOW}"
	else
		# Compare size
		[[ $AS == $SIZE ]] && SZ="${GREEN}" || SZ="${RED}"
	fi
	# Format for echo
	SZ="${SZ}SIZE"

	# Echo results
	echo -e "${RESET}${BOLD}${PKG} ${SZ} ${MD} ${SH}${RESET}"
}

while read line; do
	# If this line starts with 'CPV', it's the package name so record it
	if [[ $line == CPV* ]]; then
		PKG=$(getstr $line)
	# If this line starts with 'SIZE', record this as the file size
	elif [[ $line == SIZE* ]]; then
		SIZE=$(getstr $line)
	# If this line start with 'MD5', record this as the file MD5 sum
	elif [[ $line == MD5* ]]; then
		MD5=$(getstr $line)
	# If this file contains 'SHA1', record this as the file SHA1 sum
	elif [[ $line == SHA1* ]]; then
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
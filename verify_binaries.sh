#!/bin/bash
BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"

# Packages directory
PKGSDIR=/usr/portage/packages

# Work begins
set -e

# Get all the info we need for this process
PKGS=$(egrep "CPV|MD5|SHA1|SIZE" $PKGSDIR/Packages | awk '{print $2}')

# Initialize our 'step' counter
COUNTER=0

# Variables to store pre-recorded information about a package
PN="" # Package name
PS="" # Recorded package size
MD5="" # Recorded MD5
SHA1="" # Recorded SHA1

verify() {
	# Variables passed to this function
	# $1 = package name
	# $2 = recorded MD5
	# $3 = recorded SHA1
	# $4 = recorded package size

	# Get full package file name and path
	## BUG ALERT: we are always assuming the package ends with ".tbz2"
	local P=$PKGSDIR/$1.tbz2
	# Get actual package MD5
	local AMD5=$(md5sum $P | awk '{print $1}')
	# Get actual package SHA1
	local ASHA1=$(sha1sum $P | awk '{print $1}')
	# Get actual package size
	local AS=$(stat -c%s $P)
	# Variables to store formatted strings
	local MD=""
	local SH=""
	local SZ=""

	# Compare MD5
	[[ $AMD5 == $2 ]] && MD="${GREEN}" || MD="${RED}"
	# Format for echo
	MD="${MD}MD5"

	# Compare SHA1
	[[ $ASHA1 == $3 ]] && SH="${GREEN}" || SH="${RED}"
	# Format for echo
	SH="${SH}SHA1"

	# Compare size
	[[ $AS == $4 ]] && SZ="${GREEN}" || SZ="${RED}"
	# Format for echo
	SZ="${SZ}SIZE"

	# Echo results
	echo -e "${RESET}${BOLD}${1} ${SZ} ${MD} ${SH}${RESET}"
}

for str in $PKGS; do
	if [[ $((COUNTER % 4)) == 0 ]]; then
		if [[ $COUNTER != 0 ]]; then
			# Verify size and other things once we have enough info
			verify $PN $MD5 $SHA1 $PS
		fi
		# Package name is always found in the 'first' step
		PN=$str
	elif [[ $((COUNTER % 4)) == 1 ]]; then
		# Package MD5 sum is always found in the step after package name
		MD5=$str
	elif [[ $((COUNTER % 4)) == 2 ]]; then
		# Package SHA1 sum is always found in the step after package MD5 sum
		SHA1=$str
	else
		# Package size is always found in the 'last' step
		PS=$str
	fi
	# Keep track of our steps
	let COUNTER=COUNTER+1
done
# Verify the last package
verify $PN $MD5 $SHA1 $PS

set +e

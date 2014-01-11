#!/bin/bash
BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"

PKGSDIR=/usr/portage/packages

# Work begins
PKGS=$(egrep "CPV|MD5|SHA1|SIZE" $PKGSDIR/Packages | awk '{print $2}')
COUNTER=0

PN="" # Package name
PS="" # Recorded package size
MD5="" # Recorded MD5
SHA1="" # Recorded SHA1

set -e

verify() {
	# $1 = package name
	# $2 = recorded MD5
	# $3 = recorded SHA1
	# $4 = recorded package size

	# Get actual package size
	## BUG ALERT: we are always assuming the package ends with ".tbz2"
	local P=$PKGSDIR/$1.tbz2
	local AMD5=$(md5sum $P | awk '{print $1}')
	local ASHA1=$(sha1sum $P | awk '{print $1}')
	local AS=$(stat -c%s $P)
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
			# Verify size once we have enough info
			verify $PN $MD5 $SHA1 $PS
		fi
		# Package name is always found in even steps
		PN=$str
	elif [[ $((COUNTER % 4)) == 1 ]]; then
		MD5=$str
	elif [[ $((COUNTER % 4)) == 2 ]]; then
		SHA1=$str
	else
		# Package size is always found in odd steps
		PS=$str
	fi
	let COUNTER=COUNTER+1
done
# Verify the last package
verify $PN $MD5 $SHA1 $PS

set +e

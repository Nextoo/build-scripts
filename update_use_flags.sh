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




# (eventually source some config here, right now this is config for nextoo-desktop/nextoo-kde)
NEXTOO_GLOBAL_USE="mysql declarative qt3support X a52 aac acpi alsa apng avahi bash-completion bluray btrfs c++0x cairo cdda cddb consolekit cryptsetup cups dbus dts dvd encode fat flac fontconfig gd gif gimp gudev hfs hwdb icu jpeg kate kde libass libsamplerate mdadm mdnsresponder-compat minizip mmx mng mp3 mtp multimedia musepack nfsv41 nsplugin ntfs ocr ogg okteta openal opengl pdf pdo png policykit postgres postscript pulseaudio python qml qt4 qthelp rar rbd rdesktop realtime reviewboard rtsp samba sasl scanner script sdl sdl-image semantic-desktop shine shout speech sql sse sse2 svg switcher taglib theora tiff tools tracker transcode truetype udev upnp upnp-av v4l vaapi vcdx vnc vorbis webkit winbind x264 xcomposite xinerama xml xmp xosd xv -lcx -snappy -tor sqlite"
NEXTOO_PACKAGE_USE_app_arch__p7zip="wxwidgets"
NEXTOO_PACKAGE_USE_net_fs__cifs_utils="-acl"
NEXTOO_PACKAGE_USE_net_libs__libproxy="-webkit"
#NEXTOO_PACKAGE_USE_dev_lang__python="sqlite"


function update_global_use() {
	local oldifs="${IFS}"

	IFS=$(printf ' \n\t')
	for flag in ${NEXTOO_GLOBAL_USE}; do
		if [[ "${flag:0:1}" == '-' ]]; then
			# Because euse is broken and returns nonzero if the flag is already disabled, we have to check first
			if euse -a "${flag:1}" | egrep "^\s*${flag:1}" > /dev/null; then
				run euse -D "${flag:1}"
			fi
		else
			# Because euse is broken and returns nonzero if the flag is already enabled, we have to check first
			if ! euse -a "${flag}" | egrep "^\s*${flag//+/\+}" > /dev/null; then
				run euse -E "${flag}"
			fi
		fi
	done

	IFS="${oldifs}"
}

function update_package_use {
	local category="${1}" package="${2}" flags="${3}"
	local oldifs="${IFS}"

	IFS=$(printf ' \n\t')
	for flag in ${flags}; do
		if [[ "${flag:0:1}" == '-' ]]; then
			# euse doesn't support this yet
			#if euse -p "${category}/${package}" -a "${flag:1}" | egrep "^\s*${flag:1}" > /dev/null; then
				run euse -p "${category}/${package}" -D "${flag:1}"
			#fi
		else
			# euse doesn't support this yet
			#if ! euse -p "${category}/${package}" -a "${flag}" | egrep "^\s*${flag}" > /dev/null; then
				run euse -p "${category}/${package}" -E "${flag}"
			#fi
		fi
	done

	IFS="${oldifs}"
}


# Grabs environment variables starting with NEXTOO_PACKAGE_USE_ and calls update_package_use for each one
# Package atoms have - replaced with _, and / replaced with __.  For example: sys_kernel__nextoo_sources
function parse_environment {
	local atom category package variable
	local oldifs="${IFS}"

	IFS=$(printf ' \n\t')
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

status "Updating package USE flags..."
parse_environment

status "Updating system USE flags (this may take a while)..."
update_global_use

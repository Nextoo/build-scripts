#!/bin/bash
set -e

# This script creates a folder in the current directory and performs the setup required for development of NexToo

# Create a directory for development
mkdir nextootesting
cd nextootesting
echo 'Created and moved to new folder'

wget http://gentoo.closest.myvwan.com/gentoo/releases/amd64/current-stage3/stage3-amd64-20131010.tar.bz2
echo 'Downloaded the latest Gentoo Stage 3'

tar -xpf stage3-amd64-20131010.tar.bz2
echo 'Unpackaged Gentoo Stage 3'

wget http://gentoo.closest.myvwan.com/gentoo/snapshots/portage-latest.tar.bz2
echo 'Downloaded the latest Portage tree'

tar -xf portage-latest.tar.bz2 -C usr/
echo 'Unpackaged Portage'

mount -t proc none proc/
mount --rbind /dev dev/
mount --rbind /sys sys/
echo 'Mounted proc, dev, and sys'

cp /etc/resolv.conf etc/
echo 'Copied /etc/resolve.conf'

#copy script into the env to run mor commands, like env-update and source
chroot . #/bin/bash scriptname.sh

#env-update
#source /etc/profile

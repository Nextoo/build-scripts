#!/bin/bash
set -e

# This script creates a folder in the current directory and performs the setup required for development of NexToo

if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script!" 2>&1
  exit 1
fi

# Execute getopt
ARGS=`getopt -o "d:" -l "directory:" -n "setup_nextoo_env" -- "$@"`
 
target_dir=""
script_source_dir="$(pwd)"

#Bad arguments
if [ $? -ne 0 ];
then
  exit 1
fi
 
# A little magic
eval set -- "$ARGS"
 
# Now go through all the options
while true;
do
	case "$1" in
		-d|--directory)
			
		if [ -n "$2" ]
			then
			echo "Using $2..."
			target_dir=$2
		fi
		shift 2;;
 
	--)
		shift
		break;;
  esac
done

# Create a directory for development
if [ -z "$target_dir" ] 
then
	echo 'Must provide target directory to create and use for development environment'
	echo 'Use -d or --directory'
	echo 'Example: "setup_nextoo_env -d /tmp/nextooTesting"'
	exit 1
fi

if [ -d "$target_dir" ]
then
	echo "$target_dir already exists. Remove it and try again."
	exit 1
fi

echo "Making $2..."
mkdir "$target_dir"

echo "Changing directory to $2..."
cd "$target_dir"

echo 'Downloading the latest Gentoo Stage 3...'
wget http://gentoo.closest.myvwan.com/gentoo/releases/amd64/current-stage3/stage3-amd64-20131010.tar.bz2

echo 'Unpackaging Gentoo Stage 3...'
tar -xpf stage3-amd64-20131010.tar.bz2

echo 'Downloading the latest Portage tree...'
wget http://gentoo.closest.myvwan.com/gentoo/snapshots/portage-latest.tar.bz2

echo 'Unpackaging Portage...'
tar -xf portage-latest.tar.bz2 -C usr/

echo 'Mounting proc...'
mount -t proc none proc/

echo 'Mounting dev...'
mount --rbind /dev dev/

echo 'Mounting sys...'
mount --rbind /sys sys/

echo 'Copying /etc/resolve.conf...'
cp /etc/resolv.conf etc/

echo 'Copying nextoo_init script...'
cp "$script_source_dir/nextoo_init.sh" root/

#copy script into the env to run more commands, like env-update and source
chroot . /bin/bash -i /root/nextoo_init.sh


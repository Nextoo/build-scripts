#!/bin/bash


# Exit if a command fails
set -e

# Set command quietness
quiet_eix="-q"
quiet_portage="--quiet-build"


eix-sync "${quiet_eix}"
emerge -DNu "${quiet_portage}" @world
emerge "${quiet_portage}" --depclean
revdep-rebuild -i -- "${quiet_portage}"


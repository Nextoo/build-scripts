#!/bin/bash
set -e

echo 'Updating environment...'
env-update

echo 'Sourcing profile...'
source /etc/profile

# hack for now. Need to figure out how to start bash with this script and be left in this environment
bash
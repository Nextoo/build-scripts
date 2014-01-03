build-scripts
=============

This repository holds scripts used to automate the build, test, and deployment of NexToo.

To build NexToo binaries for a given profile, try this:

mkdir /tmp/nextoo-build
cd /tmp/nextoo-build
git clone https://github.com/nextoo/build-scripts.git
build-scripts/build.sh /tmp/nextoo-build/target nextoo:0.0.1/default/linux/amd64/server/router

(In this case, the profile is `nextoo:0.0.1/default/linux/amd64/server/router`, and `/tmp/nextoo-build/target` is the build directory)

Note that you must be root to run this since chroot is used during the environment setup.

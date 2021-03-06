build-scripts
=============

This repository holds scripts used to automate the build, test, and deployment of Nextoo.

To build Nextoo binaries for a given profile, try this:

```
mkdir /tmp/nextoo-build
cd /tmp/nextoo-build
git clone https://github.com/nextoo/build-scripts.git
./build-scripts/build.sh /tmp/nextoo-build/target server/router
```

(In this case, the profile is `server/router`, and `/tmp/nextoo-build/target` is the build directory)

Note that you must be root to run this since 'mount' is used during the environment setup, and a chroot is used for the actual build.

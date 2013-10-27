#!/bin/bash

[[ -d /tmp/binhost ]] && rm -r /tmp/binhost
/usr/lib64/portage/bin/binhost-snapshot /usr/portage/packages/ /tmp/binhost http://packages.nextoo.org/nextoo-desktop/nextoo-kde/amd64/packages /tmp
rsync -auvv --progress --stats --human-readable /tmp/Packages nextoo.org@nextoo.org:/home/nextoo.org/domains/packages.nextoo.org/public_html/nextoo-desktop/nextoo-kde/amd64/
rsync -auvv --progress --stats --human-readable /tmp/binhost/ nextoo.org@nextoo.org:/home/nextoo.org/domains/packages.nextoo.org/public_html/nextoo-desktop/nextoo-kde/amd64/packages

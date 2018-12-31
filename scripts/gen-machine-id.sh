#!/bin/sh
# Forked from Scaleway. 
# When creating multiple host OS's from a single OS image, the machine-id will be identical.
# This causes problems for Weave and potentially other appplications from differentiating machines/nodes.

set -euf -o pipefail

# Only rotate machine-id if it hasn't been done before
if [ ! -f /etc/machine-id.rotated ]
then
	# uuidgen might not be available
	# uuidgen > /etc/machine-id
	cat /proc/sys/kernel/random/uuid > /etc/machine-id
	# /var/lib/dbus/machine-id is symlinked to above
	touch /etc/machine-id.rotated
fi
